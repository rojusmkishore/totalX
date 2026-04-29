import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:total_x/models/user_model.dart';
import 'package:total_x/services/user_service.dart';
import 'package:uuid/uuid.dart';

class UserViewModel extends ChangeNotifier {
  final UserService _userService = UserService();
  List<UserModel> _users = [];
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _searchQuery;
  bool? _ageFilter;

  List<UserModel> _filteredUsers = [];

  List<UserModel> get users => _filteredUsers;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get searchQuery => _searchQuery;
  bool? get ageFilter => _ageFilter;

  UserViewModel() {
    // Moved fetchUsers() out of constructor to improve startup performance
  }

  void _updateFilteredUsers() {
    if (_searchQuery == null || _searchQuery!.isEmpty) {
      _filteredUsers = List.from(_users);
    } else {
      final query = _searchQuery!.toLowerCase();
      _filteredUsers = _users.where((u) {
        return u.name.toLowerCase().contains(query) || 
               u.phoneNumber.contains(query);
      }).toList();
    }
    notifyListeners();
  }

  Future<void> fetchUsers({bool refresh = false}) async {
    if (refresh) {
      _users = [];
      _lastDocument = null;
      _hasMore = true;
    }
    
    if (!_hasMore) return;

    _setLoading(true);
    try {
      final snapshot = await _userService.fetchUsersSnapshot(
        limit: 10,
        startAfter: _lastDocument,
        isOlder: _ageFilter,
      );

      final fetchedUsers = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      if (fetchedUsers.length < 10) {
        _hasMore = false;
      }

      if (fetchedUsers.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
        _users.addAll(fetchedUsers);
      }
      _updateFilteredUsers();
    } catch (e) {
      debugPrint('Error fetching users: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;
    await fetchUsers();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _updateFilteredUsers();
  }

  void setAgeFilter(bool? filter) {
    _ageFilter = filter;
    fetchUsers(refresh: true);
  }

  Future<void> addUser({
    required String name,
    required String phoneNumber,
    required int age,
    File? imageFile,
  }) async {
    _setLoading(true);
    try {
      final newUser = UserModel(
        id: const Uuid().v4(),
        name: name,
        phoneNumber: phoneNumber,
        age: age,
        imageUrl: '',
        createdAt: DateTime.now(),
      );
      await _userService.addUser(newUser, imageFile);
      await fetchUsers(refresh: true);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
