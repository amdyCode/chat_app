import 'package:chat_app/models/user.dart';
import 'package:chat_app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../models/chat_repository.dart';
import '../widgets/user_avatar.dart';
import 'auth_screen.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final _repository = ChatRepository();
  String _selectedFilter = 'all'; // 'all', 'online', 'recent'

  @override
  void initState() {
    super.initState();
    _repository.addListener(_onRepoUpdate);
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _repository.removeListener(_onRepoUpdate);
    _searchController.dispose();
    super.dispose();
  }

  void _onRepoUpdate() {
    if (mounted) setState(() {});
  }

  void _logout() {
    _repository.logout();
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const AuthScreen()));
  }

  void _openChat(User contact) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ChatScreen(contact: contact)));
  }

  List<User> _getFilteredContacts() {
    final query = _searchController.text.trim().toLowerCase();
    final contacts = _repository.availableContacts;

    return contacts.where((user) {
      final matchesQuery =
          query.isEmpty ||
          user.name.toLowerCase().contains(query) ||
          user.role.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query);

      bool matchesFilter = true;
      if (_selectedFilter == 'online') {
        matchesFilter = user.isOnline;
      } else if (_selectedFilter == 'recent') {
        final lastMsg = _repository.getLastMessage(user.id);
        matchesFilter = lastMsg != null;
      }

      return matchesQuery && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _repository.currentUser;
    final filteredContacts = _getFilteredContacts();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(currentUser),

            _buildSearchBar(),

            _buildFilterPills(),

            _buildSectionHeader(filteredContacts.length),

            Expanded(
              child: filteredContacts.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: filteredContacts.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final contact = filteredContacts[index];
                        return _buildContactCard(contact);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(User? currentUser) {
    final userName = currentUser?.name ?? 'Utilisateur';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            spacing: 10,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryContainer],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.chat_bubble_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  const Text(
                    'Chat',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    'Connecté en tant que $userName',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),

          Row(
            spacing: 8,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.outline,
                  size: 22,
                ),
                tooltip: 'Déconnexion',
                onPressed: _logout,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.outline, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Rechercher un contact ou une discussion...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  fillColor: Colors.transparent,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                  hintStyle: TextStyle(
                    fontSize: 13.5,
                    color: AppColors.outline,
                  ),
                ),
              ),
            ),
            if (_searchController.text.isNotEmpty)
              GestureDetector(
                onTap: () => _searchController.clear(),
                child: const Icon(
                  Icons.close,
                  color: AppColors.outline,
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPills() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        spacing: 8,
        children: [
          _buildFilterChip('all', 'Tous'),
          _buildFilterChip('online', 'En ligne'),
          _buildFilterChip('recent', 'Récents'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedFilter == key;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'UTILISATEURS AUTHENTIFIÉS ($count)',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.outline,
              letterSpacing: 0.8,
            ),
          ),
          const Text(
            'Messages instantanés',
            style: TextStyle(fontSize: 11, color: AppColors.outline),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(User contact) {
    final lastMsg = _repository.getLastMessage(contact.id);

    return InkWell(
      onTap: () => _openChat(contact),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          spacing: 12,
          children: [
            UserAvatar(
              name: contact.name,
              size: 48,
              showOnlineIndicator: true,
              isOnline: contact.isOnline,
            ),

            // User Info & Status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 3,
                children: [
                  Row(
                    spacing: 6,
                    children: [
                      Flexible(
                        child: Text(
                          contact.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: contact.isOnline
                              ? AppColors.secondaryContainer.withValues(
                                  alpha: 0.3,
                                )
                              : AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          contact.isOnline ? 'En ligne' : 'Hors ligne',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: contact.isOnline
                                ? AppColors.onSecondaryContainer
                                : AppColors.outline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    contact.role,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    lastMsg != null ? lastMsg.text : contact.statusMessage,
                    style: TextStyle(
                      fontSize: 12,
                      color: lastMsg != null
                          ? AppColors.onSurfaceVariant
                          : AppColors.outline,
                      fontStyle: lastMsg == null
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: const [
          Icon(Icons.person_search, size: 48, color: AppColors.outline),
          Text(
            'Aucun contact trouvé',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          Text(
            'Essayez un autre mot-clé ou modifiez les filtres.',
            style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
