const db = require('../../config/supabase');
const fs = require('fs').promises;
const path = require('path');
const sharp = require('sharp');

class ProfileService {
  /**
   * Get user profile by ID
   */
  async getUserProfile(userId) {
    try {
      const query = `
        SELECT 
          id, 
          email, 
          full_name, 
          phone, 
          avatar_url,
          balance,
          points,
          is_verified,
          created_at,
          updated_at
        FROM users 
        WHERE id = $1
      `;
      
      const result = await db.query(query, [userId]);
      
      if (result.rows.length === 0) {
        throw new Error('User not found');
      }
      
      // Get user statistics
      const statsQuery = `
        SELECT 
          COUNT(*) as total_bookings,
          COUNT(CASE WHEN status = 'ongoing' THEN 1 END) as ongoing_bookings,
          COUNT(CASE WHEN status = 'completed' THEN 1 END) as completed_bookings
        FROM bookings 
        WHERE user_id = $1
      `;
      
      const statsResult = await db.query(statsQuery, [userId]);
      
      return {
        ...result.rows[0],
        stats: statsResult.rows[0]
      };
    } catch (error) {
      throw error;
    }
  }

 // backend/src/services/client/profileService.js

async updateUserProfile(userId, updateData) {
  try {
    const { full_name, phone } = updateData;
    const updates = [];
    const values = [];
    let paramCount = 1;

    // PERBAIKI: Hanya tambahkan ke updates jika field ada (bukan undefined)
    if (full_name !== undefined && full_name !== null && full_name !== '') {
      updates.push(`full_name = $${paramCount++}`);
      values.push(full_name);
      console.log('📝 Updating full_name:', full_name);
    }
    
    if (phone !== undefined && phone !== null && phone !== '') {
      updates.push(`phone = $${paramCount++}`);
      values.push(phone);
      console.log('📱 Updating phone:', phone);
    }

    // TAMBAHKAN: Jika tidak ada data yang diupdate, return current user data
    if (updates.length === 0) {
      console.log('⚠️ No fields to update, returning current user');
      // Ambil data user saat ini
      const currentUser = await db.query(
        'SELECT id, email, full_name, phone, avatar_url, balance, points, is_verified FROM users WHERE id = $1',
        [userId]
      );
      if (currentUser.rows.length === 0) {
        throw new Error('User not found');
      }
      return currentUser.rows[0];
    }

    updates.push(`updated_at = NOW()`);
    values.push(userId);

    const query = `
      UPDATE users 
      SET ${updates.join(', ')}
      WHERE id = $${paramCount}
      RETURNING id, email, full_name, phone, avatar_url, balance, points, is_verified
    `;
    
    console.log('📝 Update query:', query);
    console.log('📝 Values:', values);
    
    const result = await db.query(query, values);
    
    if (result.rows.length === 0) {
      throw new Error('User not found');
    }
    
    return result.rows[0];
  } catch (error) {
    console.error('Update profile error:', error);
    throw error;
  }
}

// backend/src/services/client/profileService.js

async updateAvatar(userId, file) {
  try {
    console.log('🖼️ Starting avatar upload for user:', userId);
    
    if (!file) {
      throw new Error('No file uploaded');
    }

    // Get current user data to delete old avatar
    const currentUser = await db.query(
      'SELECT avatar_url FROM users WHERE id = $1',
      [userId]
    );

    if (currentUser.rows.length === 0) {
      throw new Error('User not found');
    }

    // Pastikan direktori uploads/avatars ada
    const uploadDir = path.join(__dirname, '../../../uploads/avatars');
    try {
      await fs.access(uploadDir);
    } catch (error) {
      console.log('📁 Creating uploads directory...');
      await fs.mkdir(uploadDir, { recursive: true });
    }

    // Process image with Sharp
    const processedFilename = `avatar-${Date.now()}-${userId}.webp`;
    const processedPath = path.join(uploadDir, processedFilename);
    
    await sharp(file.path)
      .resize(400, 400, {
        fit: 'cover',
        position: 'center'
      })
      .webp({ quality: 80 })
      .toFile(processedPath);

    // Delete old avatar file
    const oldAvatarUrl = currentUser.rows[0].avatar_url;
    if (oldAvatarUrl) {
      const oldFilename = oldAvatarUrl.split('/').pop();
      const oldPath = path.join(uploadDir, oldFilename);
      try {
        await fs.unlink(oldPath);
      } catch (err) {
        console.log('Old avatar not found:', err.message);
      }
    }

    // Delete temporary file
    await fs.unlink(file.path);

    // 🔴 PERBAIKI: Buat URL lengkap dengan BASE_URL
    const BASE_URL = process.env.BASE_URL || 'http://192.168.1.6:3000';
    const avatarUrl = `${BASE_URL}/uploads/avatars/${processedFilename}`;
    
    console.log('📸 Avatar URL:', avatarUrl);

    // Update database
    const result = await db.query(
      `UPDATE users 
       SET avatar_url = $1, updated_at = NOW() 
       WHERE id = $2 
       RETURNING id, email, full_name, avatar_url`,
      [avatarUrl, userId]
    );

    return result.rows[0];
  } catch (error) {
    if (file && file.path) {
      try {
        await fs.unlink(file.path);
      } catch (err) {
        console.log('Error deleting temp file:', err.message);
      }
    }
    throw error;
  }
}

  /**
   * Delete avatar
   */
  async deleteAvatar(userId) {
    try {
      // Get current user data
      const currentUser = await db.query(
        'SELECT avatar_url FROM users WHERE id = $1',
        [userId]
      );

      if (currentUser.rows.length === 0) {
        throw new Error('User not found');
      }

      const avatarUrl = currentUser.rows[0].avatar_url;
      
      if (avatarUrl) {
        // Delete file from filesystem
        const filename = avatarUrl.split('/').pop();
        const filePath = path.join('uploads/avatars', filename);
        try {
          await fs.unlink(filePath);
        } catch (err) {
          console.log('Avatar file not found:', err.message);
        }
      }

      // Update database
      const result = await db.query(
        `UPDATE users 
         SET avatar_url = NULL, updated_at = NOW() 
         WHERE id = $1 
         RETURNING id, email, full_name, avatar_url`,
        [userId]
      );

      return result.rows[0];
    } catch (error) {
      throw error;
    }
  }

  /**
   * Change password
   */
  async changePassword(userId, oldPassword, newPassword) {
    try {
      const bcrypt = require('bcrypt');
      
      // Get current user with password
      const user = await db.query(
        'SELECT password_hash FROM users WHERE id = $1',
        [userId]
      );

      if (user.rows.length === 0) {
        throw new Error('User not found');
      }

      // Verify old password
      const isValid = await bcrypt.compare(oldPassword, user.rows[0].password_hash);
      if (!isValid) {
        throw new Error('Current password is incorrect');
      }

      // Hash new password
      const hashedPassword = await bcrypt.hash(newPassword, 10);

      // Update password
      await db.query(
        'UPDATE users SET password_hash = $1, updated_at = NOW() WHERE id = $2',
        [hashedPassword, userId]
      );

      return { message: 'Password updated successfully' };
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get booking history
   */
  async getBookingHistory(userId, status = null) {
    try {
      let query = `
        SELECT 
          b.*,
          d.vehicle_name,
          d.vehicle_type,
          d.plate_number,
          d.price_per_hour
        FROM bookings b
        LEFT JOIN drivers d ON b.driver_id = d.id
        WHERE b.user_id = $1
      `;
      
      const values = [userId];
      
      if (status) {
        query += ` AND b.status = $2`;
        values.push(status);
      }
      
      query += ` ORDER BY b.created_at DESC`;
      
      const result = await db.query(query, values);
      return result.rows;
    } catch (error) {
      throw error;
    }
  }
}

module.exports = new ProfileService();