// controllers/authController.js
const { supabase, supabaseAdmin } = require('../config/supabase');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const register = async (req, res) => {
  try {
    const { email, password, full_name, phone } = req.body;

    // Validasi input
    if (!email || !password || !full_name) {
      return res.status(400).json({
        success: false,
        message: 'Email, password, dan full name harus diisi'
      });
    }

    if (password.length < 6) {
      return res.status(400).json({
        success: false,
        message: 'Password minimal 6 karakter'
      });
    }

    // Validasi format email
    const emailRegex = /^[^\s@]+@([^\s@.,]+\.)+[^\s@.,]{2,}$/;
    if (!emailRegex.test(email)) {
      return res.status(400).json({
        success: false,
        message: 'Format email tidak valid'
      });
    }

    const cleanEmail = email.toLowerCase().trim();

    // Cek apakah user sudah ada di tabel users
    const { data: existingUser, error: checkError } = await supabase
      .from('users')
      .select('email')
      .eq('email', cleanEmail)
      .maybeSingle();

    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'Email sudah terdaftar'
      });
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const password_hash = await bcrypt.hash(password, salt);

    // Buat user di tabel users
    const { data: user, error: dbError } = await supabase
      .from('users')
      .insert([
        {
          email: cleanEmail,
          password_hash: password_hash,
          full_name: full_name.trim(),
          phone: phone?.trim() || null,
          balance: 0,
          points: 0,
          is_verified: true,
          created_at: new Date(),
          updated_at: new Date()
        }
      ])
      .select()
      .single();

    if (dbError) {
      console.error('DB Error:', dbError);
      return res.status(400).json({
        success: false,
        message: 'Gagal mendaftar: ' + dbError.message
      });
    }

    // Opsional: Buat user di Supabase Auth
    try {
      await supabaseAdmin.auth.admin.createUser({
        email: cleanEmail,
        password: password,
        email_confirm: true,
        user_metadata: {
          full_name: full_name.trim(),
          phone: phone?.trim() || ''
        }
      });
    } catch (authError) {
      console.warn('Supabase Auth creation failed (non-critical):', authError.message);
    }

    // Buat token JWT
    const token = jwt.sign(
      { id: user.id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRE || '7d' }
    );

    // Hapus password_hash dari response
    const { password_hash: _, ...userWithoutPassword } = user;

    res.status(201).json({
      success: true,
      message: 'Registrasi berhasil',
      data: {
        user: userWithoutPassword,
        token: token
      }
    });
    
  } catch (error) {
    console.error('Register error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan pada server: ' + error.message
    });
  }
};

const login = async (req, res) => {
  try {
    const { email, password } = req.body;
    
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Email dan password harus diisi'
      });
    }
    
    const cleanEmail = email.toLowerCase().trim();
    
    console.log('\n═══════════════════════════════════════════════════');
    console.log('🔐 LOGIN REQUEST');
    console.log(`📧 Email: ${cleanEmail}`);
    console.log('═══════════════════════════════════════════════════');

    // Cari user di database berdasarkan email
    const { data: user, error } = await supabase
      .from('users')
      .select('*')
      .eq('email', cleanEmail)
      .maybeSingle();

    if (error) {
      console.error('❌ Database error:', error);
      return res.status(401).json({
        success: false,
        message: 'Email atau password salah'
      });
    }

    if (!user) {
      console.log('❌ User not found with email:', cleanEmail);
      return res.status(401).json({
        success: false,
        message: 'Email atau password salah'
      });
    }

    console.log('✅ User found:', user.email);

    // Verifikasi password
    if (!user.password_hash) {
      console.error('❌ No password_hash for user');
      return res.status(401).json({
        success: false,
        message: 'Email atau password salah'
      });
    }
    
    const isPasswordValid = await bcrypt.compare(password, user.password_hash);
    console.log('🔑 Password valid:', isPasswordValid);

    if (!isPasswordValid) {
      console.log('❌ Invalid password');
      return res.status(401).json({
        success: false,
        message: 'Email atau password salah'
      });
    }

    console.log('✅ Login successful!');
    console.log('═══════════════════════════════════════════════════\n');

    // Generate token JWT
    const token = jwt.sign(
      { 
        id: user.id, 
        email: user.email,
        full_name: user.full_name 
      },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRE || '7d' }
    );

    // Hapus password_hash dari response
    const { password_hash: _, ...userWithoutPassword } = user;

    res.status(200).json({
      success: true,
      message: 'Login berhasil',
      data: {
        user: userWithoutPassword,
        token: token
      }
    });
    
  } catch (error) {
    console.error('❌ Login error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan pada server'
    });
  }
};

// Get Current User
const getMe = async (req, res) => {
  try {
    const { password_hash: _, ...userWithoutPassword } = req.user;
    res.status(200).json({
      success: true,
      data: userWithoutPassword
    });
  } catch (error) {
    console.error('GetMe error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// Update Profile
const updateProfile = async (req, res) => {
  try {
    const { full_name, phone, avatar_url } = req.body;
    const userId = req.user.id;

    const { data: user, error } = await supabase
      .from('users')
      .update({
        full_name: full_name?.trim(),
        phone: phone?.trim(),
        avatar_url: avatar_url,
        updated_at: new Date()
      })
      .eq('id', userId)
      .select()
      .single();

    if (error) {
      console.error('Update profile error:', error);
      return res.status(400).json({
        success: false,
        message: error.message
      });
    }

    const { password_hash: _, ...userWithoutPassword } = user;

    res.status(200).json({
      success: true,
      message: 'Profil berhasil diupdate',
      data: userWithoutPassword
    });
  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// Export semua fungsi
module.exports = {
  register,
  login,
  getMe,
  updateProfile
};