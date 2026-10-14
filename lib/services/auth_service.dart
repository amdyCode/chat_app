import 'dart:async';
import 'package:chat_app/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:get/get.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find<AuthService>();

  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  fb.FirebaseAuth get firebaseAuth => _auth;

  final Rxn<User> currentUser = Rxn<User>();
  final RxList<User> users = <User>[].obs;

  bool get isAuthenticated => _auth.currentUser != null;

  StreamSubscription<fb.User?>? _authSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _usersSubscription;

  @override
  void onInit() {
    super.onInit();
    _bindAuthAndUsers();
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    _usersSubscription?.cancel();
    super.onClose();
  }

  void _bindAuthAndUsers() {
    // 1. Écouter les changements d'état d'authentification Firebase
    _authSubscription = _auth.authStateChanges().listen((fb.User? fbUser) async {
      if (fbUser != null) {
        await _fetchOrCreateUserProfile(fbUser);
      } else {
        currentUser.value = null;
      }
    });

    // 2. Écouter la collection des utilisateurs Firestore en temps réel
    _usersSubscription = _firestore.collection('users').snapshots().listen(
      (snapshot) {
        final loadedUsers = snapshot.docs.map((doc) {
          final data = doc.data();
          return User.fromMap(data);
        }).toList();

        users.assignAll(loadedUsers);
      },
      onError: (err) {
        users.clear();
      },
    );
  }

  Future<void> _fetchOrCreateUserProfile(fb.User fbUser) async {
    try {
      final docRef = _firestore.collection('users').doc(fbUser.uid);
      final doc = await docRef.get();

      if (doc.exists && doc.data() != null) {
        currentUser.value = User.fromMap(doc.data()!);
        await docRef.update({
          'isOnline': true,
          'lastSeen': DateTime.now().millisecondsSinceEpoch,
        });
      } else {
        final cleanName = fbUser.displayName?.trim().isNotEmpty == true
            ? fbUser.displayName!.trim()
            : (fbUser.email?.split('@').first ?? 'Utilisateur');

        final newUser = User(
          id: fbUser.uid,
          name: cleanName,
          email: fbUser.email ?? '',
          role: 'Membre actif',
          isOnline: true,
          lastSeen: DateTime.now(),
          statusMessage: 'En ligne',
        );
        await docRef.set(newUser.toMap());
        currentUser.value = newUser;
      }
    } catch (_) {
      currentUser.value = User(
        id: fbUser.uid,
        name: fbUser.displayName ?? fbUser.email?.split('@').first ?? 'Utilisateur',
        email: fbUser.email ?? '',
        role: 'Membre actif',
        isOnline: true,
        lastSeen: DateTime.now(),
      );
    }
  }

  // Connexion Firebase Authentication
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        await _fetchOrCreateUserProfile(credential.user!);
      }
      return true;
    } on fb.FirebaseAuthException catch (e) {
      throw _getReadableAuthError(e.code);
    } catch (e) {
      throw 'Une erreur inattendue est survenue: $e';
    }
  }

  // Inscription Firebase Authentication + Sauvegarde du profil
  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final fbUser = credential.user;
      if (fbUser != null) {
        final cleanName = fullName.trim().isNotEmpty
            ? fullName.trim()
            : email.split('@').first;

        await fbUser.updateDisplayName(cleanName);

        final newUser = User(
          id: fbUser.uid,
          name: cleanName,
          email: email.trim(),
          role: 'Membre actif',
          isOnline: true,
          lastSeen: DateTime.now(),
          statusMessage: 'Connecté(e)',
        );

        try {
          await _firestore.collection('users').doc(fbUser.uid).set(newUser.toMap());
        } catch (_) {}

        currentUser.value = newUser;
      }
      return true;
    } on fb.FirebaseAuthException catch (e) {
      throw _getReadableAuthError(e.code);
    } catch (e) {
      throw 'Une erreur inattendue est survenue: $e';
    }
  }

  // Déconnexion Firebase Authentication
  Future<void> logout() async {
    try {
      if (currentUser.value != null) {
        try {
          await _firestore.collection('users').doc(currentUser.value!.id).update({
            'isOnline': false,
            'lastSeen': DateTime.now().millisecondsSinceEpoch,
          });
        } catch (_) {}
      }
      await _auth.signOut();
      currentUser.value = null;
    } catch (e) {
      currentUser.value = null;
    }
  }

  // Réinitialisation de mot de passe par email via Firebase
  Future<void> sendPasswordResetEmail(String email) async {
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty) {
      throw 'Veuillez saisir votre adresse email.';
    }
    try {
      await _auth.sendPasswordResetEmail(email: cleanEmail);
    } on fb.FirebaseAuthException catch (e) {
      throw _getReadableAuthError(e.code);
    } catch (e) {
      throw 'Impossible d\'envoyer l\'email de réinitialisation: $e';
    }
  }

  // Feature 4: Bloquer / Débloquer un contact
  void toggleBlockUser(String targetUserId) {
    if (currentUser.value == null) return;

    final blocked = List<String>.from(currentUser.value!.blockedUserIds);
    if (blocked.contains(targetUserId)) {
      blocked.remove(targetUserId);
    } else {
      blocked.add(targetUserId);
    }

    currentUser.value = currentUser.value!.copyWith(blockedUserIds: blocked);

    try {
      _firestore.collection('users').doc(currentUser.value!.id).update({
        'blockedUserIds': blocked,
      });
    } catch (_) {}
  }

  bool isUserBlocked(String userId) {
    return currentUser.value?.isUserBlocked(userId) ?? false;
  }

  // Traduction des erreurs Firebase en messages clairs pour l'utilisateur
  String _getReadableAuthError(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email ou mot de passe incorrect.';
      case 'email-already-in-use':
        return 'Cette adresse email est déjà utilisée par un autre compte.';
      case 'weak-password':
        return 'Le mot de passe doit comporter au moins 6 caractères.';
      case 'invalid-email':
        return 'Le format de l\'adresse email est invalide.';
      case 'user-disabled':
        return 'Ce compte utilisateur a été désactivé.';
      case 'too-many-requests':
        return 'Trop de tentatives infructueuses. Veuillez réessayer plus tard.';
      case 'network-request-failed':
        return 'Erreur réseau : vérifiez votre connexion Internet.';
      default:
        return 'Échec de l\'authentification ($code).';
    }
  }
}
