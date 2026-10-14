import 'dart:async';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ChatService extends GetxService {
  static ChatService get to => Get.find<ChatService>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<Message> messages = <Message>[].obs;
  final RxMap<String, Map<String, dynamic>> chatsData = <String, Map<String, dynamic>>{}.obs;
  final RxMap<String, bool> typingStatus = <String, bool>{}.obs;

  final RxnString activeContactId = RxnString();

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _chatsSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _activeChatSubscription;
  Worker? _authWorker;

  @override
  void onInit() {
    super.onInit();

    _authWorker = ever(AuthService.to.currentUser, (user) {
      if (user != null) {
        _listenToUserChats(user.id);
      } else {
        _cleanupSubscriptions();
      }
    });

    if (AuthService.to.currentUser.value != null) {
      _listenToUserChats(AuthService.to.currentUser.value!.id);
    }
  }

  @override
  void onClose() {
    _cleanupSubscriptions();
    _authWorker?.dispose();
    super.onClose();
  }

  void _cleanupSubscriptions() {
    _chatsSubscription?.cancel();
    _activeChatSubscription?.cancel();
    chatsData.clear();
    messages.clear();
    typingStatus.clear();
    activeContactId.value = null;
  }

  String getChatId(String uid1, String uid2) {
    return uid1.compareTo(uid2) < 0 ? '${uid1}_$uid2' : '${uid2}_$uid1';
  }

  // Écoute de l'ensemble des discussions de l'utilisateur pour la page d'accueil
  void _listenToUserChats(String myId) {
    _chatsSubscription?.cancel();

    _chatsSubscription = _firestore
        .collection('chats')
        .where('participants', arrayContains: myId)
        .snapshots()
        .listen(
      (snapshot) {
        final Map<String, Map<String, dynamic>> updated = {};
        for (final doc in snapshot.docs) {
          final data = doc.data();
          updated[doc.id] = data;

          final typingMap = data['typing'] as Map<String, dynamic>?;
          if (typingMap != null) {
            for (final entry in typingMap.entries) {
              if (entry.key != myId) {
                typingStatus[entry.key] = entry.value == true;
              }
            }
          }
        }
        chatsData.assignAll(updated);
      },
      onError: (_) {},
    );
  }

  // Écoute en temps réel des messages de la discussion active
  void bindMessagesForContact(String contactId) {
    final myId = AuthService.to.currentUser.value?.id;
    if (myId == null) return;

    _activeChatSubscription?.cancel();
    activeContactId.value = contactId;

    final chatId = getChatId(myId, contactId);

    _activeChatSubscription = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen(
      (snapshot) {
        final loadedMessages = snapshot.docs.map((doc) {
          final data = doc.data();
          return Message.fromMap(data);
        }).toList();

        messages.assignAll(loadedMessages);

        // Marquer automatiquement comme lus les messages reçus
        markMessagesAsRead(contactId: contactId);
      },
      onError: (_) {},
    );
  }

  void unbindMessagesForContact(String contactId) {
    if (activeContactId.value == contactId) {
      _activeChatSubscription?.cancel();
      activeContactId.value = null;
      messages.clear();
    }
  }

  // Envoi d'un message dans Firestore
  Future<bool> sendMessage({required String receiverId, required String text}) async {
    final myId = AuthService.to.currentUser.value?.id;
    if (myId == null) return false;

    if (AuthService.to.isUserBlocked(receiverId)) {
      Get.snackbar(
        'Action impossible',
        'Vous avez bloqué ce contact. Débloquez-le pour envoyer un message.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;

    final now = DateTime.now();
    final chatId = getChatId(myId, receiverId);
    final messagesRef = _firestore.collection('chats').doc(chatId).collection('messages');
    final docRef = messagesRef.doc();
    final messageId = docRef.id;

    final newMessage = Message(
      id: messageId,
      senderId: myId,
      receiverId: receiverId,
      text: trimmed,
      timestamp: now,
      receipt: MessageReceipt.sent,
    );

    // Affichage instantané en 0 ms pour l'expéditeur
    if (activeContactId.value == receiverId) {
      messages.add(newMessage);
    }

    try {
      final batch = _firestore.batch();

      // 1. Sauvegarder le message
      batch.set(docRef, newMessage.toMap());

      // 2. Mettre à jour les métadonnées de la discussion
      final chatRef = _firestore.collection('chats').doc(chatId);
      batch.set(
        chatRef,
        {
          'id': chatId,
          'participants': [myId, receiverId],
          'lastMessage': trimmed,
          'lastMessageSenderId': myId,
          'lastMessageTimestamp': now.millisecondsSinceEpoch,
          'unreadCount': {
            receiverId: FieldValue.increment(1),
          },
        },
        SetOptions(merge: true),
      );

      await batch.commit();
      return true;
    } catch (e) {
      if (activeContactId.value == receiverId) {
        messages.removeWhere((m) => m.id == messageId);
      }
      Get.snackbar(
        'Erreur d\'envoi',
        'Impossible d\'envoyer le message: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // Statut "en train d'écrire" dans Firestore
  void setMyTyping({required String contactId, required bool isTyping}) {
    final myId = AuthService.to.currentUser.value?.id;
    if (myId == null) return;

    final chatId = getChatId(myId, contactId);
    _firestore.collection('chats').doc(chatId).set(
      {
        'typing': {
          myId: isTyping,
        },
      },
      SetOptions(merge: true),
    ).catchError((_) {});
  }

  bool isContactTyping(String contactId) {
    return typingStatus[contactId] ?? false;
  }

  bool isContactOnline(String contactId) {
    return AuthService.to.users.firstWhereOrNull((u) => u.id == contactId)?.isOnline ?? false;
  }

  DateTime? getContactLastSeen(String contactId) {
    return AuthService.to.users.firstWhereOrNull((u) => u.id == contactId)?.lastSeen;
  }

  // Marquer les messages comme lus dans Firestore
  Future<void> markMessagesAsRead({required String contactId}) async {
    final myId = AuthService.to.currentUser.value?.id;
    if (myId == null) return;

    final chatId = getChatId(myId, contactId);

    try {
      // 1. Réinitialiser le compteur de non-lus
      await _firestore.collection('chats').doc(chatId).set(
        {
          'unreadCount': {
            myId: 0,
          },
        },
        SetOptions(merge: true),
      );

      // 2. Mettre à jour les messages non lus reçus
      final unreadQuery = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('receiverId', isEqualTo: myId)
          .where('receipt', isNotEqualTo: MessageReceipt.read.name)
          .get();

      if (unreadQuery.docs.isNotEmpty) {
        final batch = _firestore.batch();
        final nowMs = DateTime.now().millisecondsSinceEpoch;
        for (final doc in unreadQuery.docs) {
          batch.update(doc.reference, {
            'receipt': MessageReceipt.read.name,
            'readAt': nowMs,
          });
        }
        await batch.commit();
      }
    } catch (_) {}
  }

  int getUnreadCount(String contactId) {
    final myId = AuthService.to.currentUser.value?.id;
    if (myId == null) return 0;

    final chatId = getChatId(myId, contactId);
    final chat = chatsData[chatId];
    if (chat == null) return 0;

    final unreadMap = chat['unreadCount'] as Map<String, dynamic>?;
    final count = unreadMap?[myId];
    if (count is int) return count > 0 ? count : 0;
    return 0;
  }

  int getTotalUnreadCount() {
    final myId = AuthService.to.currentUser.value?.id;
    if (myId == null) return 0;

    int total = 0;
    for (final chat in chatsData.values) {
      final unreadMap = chat['unreadCount'] as Map<String, dynamic>?;
      final count = unreadMap?[myId];
      if (count is int && count > 0) {
        total += count;
      }
    }
    return total;
  }

  List<Message> getMessagesForContact(String contactId) {
    return messages;
  }

  Message? getLastMessageForContact(String contactId) {
    final myId = AuthService.to.currentUser.value?.id;
    if (myId == null) return null;

    final chatId = getChatId(myId, contactId);
    final chat = chatsData[chatId];
    if (chat == null || chat['lastMessage'] == null) return null;

    final lastTimestamp = chat['lastMessageTimestamp'] as int? ?? 0;
    return Message(
      id: '',
      senderId: chat['lastMessageSenderId'] as String? ?? '',
      receiverId: myId,
      text: chat['lastMessage'] as String? ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(lastTimestamp),
    );
  }
}
