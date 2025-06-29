import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  static const String _userKey = 'user_data';
  static const String _tokenKey = 'auth_token';
  
  final AuthService _authService = AuthService();
  
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null && _token != null;

  AuthProvider() {
    _loadUserData();
  }

  Future<void> init() async {
    await _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userKey);
      final token = prefs.getString(_tokenKey);
      
      if (userData != null && token != null) {
        _user = User.fromJson(Map<String, dynamic>.from(
          Map.from(userData as Map)
        ));
        _token = token;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to load user data: $e';
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.login(email, password);
      
      if (result['success'] == true) {
        _user = User.fromJson(result['user']);
        _token = result['token'];
        
        await _saveUserData();
        _setLoading(false);
        return true;
      } else {
        _error = result['message'] ?? 'Login failed';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Login failed: $e';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register(String email, String password, String firstName, String lastName) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.register(email, password, firstName, lastName);
      
      if (result['success'] == true) {
        _user = User.fromJson(result['user']);
        _token = result['token'];
        
        await _saveUserData();
        _setLoading(false);
        return true;
      } else {
        _error = result['message'] ?? 'Registration failed';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Registration failed: $e';
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    try {
      if (_token != null) {
        await _authService.logout(_token!);
      }
    } catch (e) {
      // Log error but don't prevent logout
      if (kDebugMode) {
        print('Logout error: $e');
      }
    }
    
    _user = null;
    _token = null;
    _error = null;
    
    await _clearUserData();
    notifyListeners();
  }

  Future<bool> refreshToken() async {
    if (_token == null) return false;
    
    try {
      final result = await _authService.refreshToken(_token!);
      
      if (result['success'] == true) {
        _token = result['token'];
        if (result['user'] != null) {
          _user = User.fromJson(result['user']);
        }
        
        await _saveUserData();
        notifyListeners();
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Token refresh error: $e');
      }
    }
    
    return false;
  }

  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    if (_token == null) return false;
    
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.updateProfile(_token!, profileData);
      
      if (result['success'] == true) {
        _user = User.fromJson(result['user']);
        await _saveUserData();
        _setLoading(false);
        return true;
      } else {
        _error = result['message'] ?? 'Profile update failed';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Profile update failed: $e';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    if (_token == null) return false;
    
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.changePassword(_token!, currentPassword, newPassword);
      
      if (result['success'] == true) {
        _setLoading(false);
        return true;
      } else {
        _error = result['message'] ?? 'Password change failed';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Password change failed: $e';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.forgotPassword(email);
      
      if (result['success'] == true) {
        _setLoading(false);
        return true;
      } else {
        _error = result['message'] ?? 'Password reset failed';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = 'Password reset failed: $e';
      _setLoading(false);
      return false;
    }
  }

  void updateUserXp(int xpGained) {
    if (_user == null) return;
    
    _user = _user!.copyWith(
      xp: _user!.xp + xpGained,
      level: _calculateLevel(_user!.xp + xpGained),
    );
    
    _saveUserData();
    notifyListeners();
  }

  void updateUserStreak(int newStreak) {
    if (_user == null) return;
    
    _user = _user!.copyWith(
      currentStreak: newStreak,
      longestStreak: newStreak > _user!.longestStreak ? newStreak : _user!.longestStreak,
    );
    
    _saveUserData();
    notifyListeners();
  }

  int _calculateLevel(int xp) {
    if (xp < 100) return 1;
    
    int level = 1;
    int remainingXp = xp;
    
    while (remainingXp >= (100 + (level - 1) * 50)) {
      remainingXp -= (100 + (level - 1) * 50);
      level++;
      if (level >= 100) break;
    }
    
    return level;
  }

  Future<void> _saveUserData() async {
    if (_user == null || _token == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, _user!.toJson().toString());
      await prefs.setString(_tokenKey, _token!);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving user data: $e');
      }
    }
  }

  Future<void> _clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.remove(_tokenKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing user data: $e');
      }
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }
}
