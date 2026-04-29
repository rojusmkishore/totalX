import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:total_x/viewmodels/auth_viewmodel.dart';
import 'package:total_x/viewmodels/user_viewmodel.dart';
import 'package:total_x/widgets/add_user_bottom_sheet.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Fetch users after the first frame to keep startup smooth
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<UserViewModel>().fetchUsers();
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<UserViewModel>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<UserViewModel>(
          builder: (context, userVM, child) {
            return AlertDialog(
              title: const Text('Sort by Age'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<bool?>(
                    title: const Text('All'),
                    value: null,
                    groupValue: userVM.ageFilter,
                    onChanged: (val) {
                      userVM.setAgeFilter(val);
                      Navigator.pop(context);
                    },
                  ),
                  RadioListTile<bool?>(
                    title: const Text('Older (> 60)'),
                    value: true,
                    groupValue: userVM.ageFilter,
                    onChanged: (val) {
                      userVM.setAgeFilter(val);
                      Navigator.pop(context);
                    },
                  ),
                  RadioListTile<bool?>(
                    title: const Text('Younger (< 60)'),
                    value: false,
                    groupValue: userVM.ageFilter,
                    onChanged: (val) {
                      userVM.setAgeFilter(val);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final userViewModel = context.watch<UserViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        title: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            const Text(
              'Nilambur',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => authViewModel.signOut(),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.search, color: Colors.grey),
                        hintText: 'Search by name',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                      onChanged: (val) => userViewModel.setSearchQuery(val),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => _showFilterDialog(context),
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.tune, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Text(
              'Users List',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: userViewModel.isLoading && userViewModel.users.isEmpty
                ? const Center(child: CircularProgressIndicator(color: Colors.black))
                : userViewModel.users.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text('No users found', style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: Colors.black,
                        onRefresh: () => userViewModel.fetchUsers(refresh: true),
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(bottom: 100),
                          itemCount: userViewModel.users.length + (userViewModel.hasMore && userViewModel.isLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == userViewModel.users.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)),
                              );
                            }
                            final user = userViewModel.users[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                leading: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey[200],
                                    image: user.imageUrl.isNotEmpty
                                        ? DecorationImage(image: NetworkImage(user.imageUrl), fit: BoxFit.cover)
                                        : null,
                                  ),
                                  child: user.imageUrl.isEmpty ? const Icon(Icons.person, color: Colors.grey) : null,
                                ),
                                title: Text(
                                  user.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    'Age: ${user.age}',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddUserBottomSheet(),
          );
        },
        backgroundColor: Colors.black,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}
