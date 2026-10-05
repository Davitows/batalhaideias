import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/ideia.dart';

class IdeiaService {
  final CollectionReference<Map<String, dynamic>> _colecao =
      FirebaseFirestore.instance.collection('ideias');

  Stream<List<Ideia>> listarIdeias() {
    return _colecao.snapshots().map((snapshot) {
      final ideias = snapshot.docs.map(Ideia.fromFirestore).toList();
      ideias.sort((a, b) => b.votos.compareTo(a.votos));
      return ideias;
    });
  }

  Future<void> cadastrar({
    required String titulo,
    required String descricao,
    required String autor,
  }) async {
    await _colecao.add({
      'titulo': titulo.trim(),
      'descricao': descricao.trim(),
      'autor': autor.trim(),
      'votos': 0,
    });
  }

  Future<void> votar(String id) async {
    await _colecao.doc(id).update({
      'votos': FieldValue.increment(1),
    });
  }

  Future<void> excluir(String id) async {
    await _colecao.doc(id).delete();
  }
}
