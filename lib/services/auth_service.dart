import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';

/// ========================================
/// AUTH SERVICE - Firebase Authentication
/// Handles all authentication and user data operations
/// ========================================
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ========================================
  // GETTERS
  // ========================================

  /// Get current Firebase user
  User? get currentUser => _auth.currentUser;

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ========================================
  // AUTHENTICATION METHODS
  // ========================================

  /// Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user != null) {
        return await getUserData(userCredential.user!.uid);
      }

      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }

  /// Register with email and password
  /// Optionally uploads profile image to Firebase Storage
  Future<UserModel?> registerWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
    File? profileImage,
  }) async {
    try {
      // Create user account
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user != null) {
        final uid = userCredential.user!.uid;
        String? photoURL;

        // Upload profile image if provided
        if (profileImage != null) {
          photoURL = await _uploadProfileImage(uid, profileImage);
        }

        // Update display name and photo URL in Firebase Auth
        if (displayName != null) {
          await userCredential.user!.updateDisplayName(displayName);
        }
        if (photoURL != null) {
          await userCredential.user!.updatePhotoURL(photoURL);
        }

        // Create user document in Firestore
        final userModel = UserModel.fromFirebaseUser(
          uid: uid,
          email: email.trim(),
          displayName: displayName,
          photoURL: photoURL,
        );

        await _createUserDocument(userModel);

        return userModel;
      }

      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Gagal keluar. Silakan coba lagi.';
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Gagal mengirim email reset password.';
    }
  }

  // ========================================
  // PROFILE UPDATE METHODS
  // ========================================

  /// Update user profile (display name and photo URL)
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'User tidak ditemukan';

      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }

      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }

      await user.reload();
    } catch (e) {
      throw 'Gagal memperbarui profil.';
    }
  }

  /// Update profile with new image file
  Future<String?> updateProfileImage(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'User tidak ditemukan';

      // Upload new image
      final photoURL = await _uploadProfileImage(user.uid, imageFile);

      // Update Firebase Auth profile
      await user.updatePhotoURL(photoURL);

      // Update Firestore document
      await updateUserData(user.uid, {'photoURL': photoURL});

      return photoURL;
    } catch (e) {
      throw 'Gagal memperbarui foto profil.';
    }
  }

  /// Update email
  Future<void> updateEmail(String newEmail) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'User tidak ditemukan';

      await user.verifyBeforeUpdateEmail(newEmail.trim());
      await user.reload();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Gagal memperbarui email.';
    }
  }

  /// Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'User tidak ditemukan';

      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Gagal memperbarui password.';
    }
  }

  /// Re-authenticate user (required before sensitive operations)
  Future<void> reauthenticate(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'User tidak ditemukan';

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Gagal memverifikasi password.';
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'User tidak ditemukan';

      // Delete profile image from storage
      try {
        await _storage.ref('profile_images/${user.uid}').delete();
      } catch (_) {
        // Ignore if image doesn't exist
      }

      // Delete user document from Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete user authentication
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Gagal menghapus akun.';
    }
  }

  // ========================================
  // FIRESTORE DATA METHODS
  // ========================================

  /// Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }

      return null;
    } catch (e) {
      throw 'Gagal mengambil data user.';
    }
  }

  /// Stream of user data from Firestore
  Stream<UserModel?> getUserDataStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    });
  }

  /// Create user document in Firestore
  Future<void> _createUserDocument(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toFirestore());
    } catch (e) {
      throw 'Gagal membuat data user.';
    }
  }

  /// Update user document in Firestore
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      throw 'Gagal memperbarui data user.';
    }
  }

  /// Check if email is already registered
  Future<bool> isEmailRegistered(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email.trim());
      return methods.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // ========================================
  // STORAGE METHODS
  // ========================================

  /// Upload profile image to Firebase Storage
  /// Returns the download URL
  Future<String> _uploadProfileImage(String uid, File imageFile) async {
    try {
      final ref = _storage.ref('profile_images/$uid');

      // Upload file with metadata
      final uploadTask = await ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Get download URL
      final downloadURL = await uploadTask.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      throw 'Gagal mengupload foto profil.';
    }
  }

  // ========================================
  // ERROR HANDLING
  // ========================================

  /// Handle Firebase Auth exceptions and return user-friendly messages
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Email tidak terdaftar';
      case 'wrong-password':
        return 'Password salah';
      case 'email-already-in-use':
        return 'Email sudah terdaftar';
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'weak-password':
        return 'Password terlalu lemah (minimal 6 karakter)';
      case 'user-disabled':
        return 'Akun telah dinonaktifkan';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Silakan coba lagi nanti';
      case 'operation-not-allowed':
        return 'Operasi tidak diizinkan';
      case 'requires-recent-login':
        return 'Silakan login ulang untuk melanjutkan';
      case 'invalid-credential':
        return 'Email atau password tidak valid';
      default:
        return e.message ?? 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }
}
