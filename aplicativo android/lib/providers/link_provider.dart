import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/link_service.dart';

class LinkProvider extends ChangeNotifier {
  String? _pairingCode;
  DateTime? _codeExpiresAt;
  bool _linked = false;
  String? _partnerName;
  int? _partnerId;
  String? _role;
  bool _loading = false;
  String? _error;

  String? get pairingCode => _pairingCode;
  DateTime? get codeExpiresAt => _codeExpiresAt;
  bool get linked => _linked;
  String? get partnerName => _partnerName;
  int? get partnerId => _partnerId;
  int? get linkedChildId => _linked ? _partnerId : null;
  bool get loading => _loading;
  String? get error => _error;

  Future<bool> generateCode() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final json = await LinkService.generateCode();
      _pairingCode = json['code'];
      _codeExpiresAt = DateTime.parse(json['expires_at'].toString());
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> pairWithCode(String code) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final json = await LinkService.pairWithCode(code);
      final link = json['link'];
      _linked = true;
      _partnerId = link['parent_id'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('partner_id', _partnerId!);
      // Save device_token returned by backend for this child device
      if (json['device_token'] != null) {
        await prefs.setString('device_token', json['device_token']);
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> checkStatus() async {
    try {
      final json = await LinkService.status();
      _linked = json['linked'] ?? false;
      _role = json['role'];
      if (_linked && json['partner'] != null) {
        _partnerName = json['partner']['name'];
        _partnerId = json['partner']['id'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('partner_id', _partnerId!);
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> restoreLinkedChild() async {
    final prefs = await SharedPreferences.getInstance();
    _partnerId = prefs.getInt('partner_id');
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
