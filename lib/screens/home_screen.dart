import 'package:flutter/material.dart';

import '../models/ideia.dart';
import '../services/ideia_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final IdeiaService _service = IdeiaService();

  Future<void> _abrirCadastro() async {
    final tituloController = TextEditingController();
    final descricaoController = TextEditingController();
    final autorController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cadastrar nova ideia'),
          content: SizedBox(
            width: 480,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: tituloController,
                      decoration: const InputDecoration(
                        labelText: 'Título',
                        prefixIcon: Icon(Icons.lightbulb_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe o título.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descricaoController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                        prefixIcon: Icon(Icons.description_outlined),
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe a descrição.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: autorController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do autor',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe o autor.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.save_outlined),
              label: const Text('Salvar'),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                try {
                  await _service.cadastrar(
                    titulo: tituloController.text,
                    descricao: descricaoController.text,
                    autor: autorController.text,
                  );

                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                } catch (e) {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(content: Text('Erro ao salvar: $e')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );

    tituloController.dispose();
    descricaoController.dispose();
    autorController.dispose();
  }

  Future<void> _confirmarExclusao(Ideia ideia) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir ideia?'),
        content: Text(
          'A ideia "${ideia.titulo}" será removida do Firestore para todos os usuários.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await _service.excluir(ideia.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir: $e')),
        );
      }
    }
  }

  Future<void> _votar(Ideia ideia) async {
    try {
      await _service.votar(ideia.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao votar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bolt_rounded),
            SizedBox(width: 8),
            Text(
              'Batalha de Ideias',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirCadastro,
        icon: const Icon(Icons.add),
        label: const Text('Nova ideia'),
      ),
      body: StreamBuilder<List<Ideia>>(
        stream: _service.listarIdeias(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _MensagemCentral(
              icon: Icons.error_outline,
              titulo: 'Erro ao carregar ideias',
              mensagem: 'Verifique a configuração do Firebase/Firestore.',
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final ideias = snapshot.data ?? [];

          if (ideias.isEmpty) {
            return const _MensagemCentral(
              icon: Icons.lightbulb_outline,
              titulo: 'Nenhuma ideia cadastrada',
              mensagem: 'Cadastre a primeira ideia usando o botão abaixo.',
            );
          }

          final maisVotada = ideias.first;

          return LayoutBuilder(
            builder: (context, constraints) {
              final largura = constraints.maxWidth;
              final padding = largura > 900 ? largura * 0.12 : 20.0;

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  padding,
                  24,
                  padding,
                  100,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _RankingCard(ideia: maisVotada),
                    const SizedBox(height: 24),
                    Text(
                      'Ideias cadastradas',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 14),
                    ...ideias.map(
                      (ideia) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _IdeiaCard(
                          ideia: ideia,
                          onVotar: () => _votar(ideia),
                          onExcluir: () => _confirmarExclusao(ideia),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _RankingCard extends StatelessWidget {
  final Ideia ideia;

  const _RankingCard({required this.ideia});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xFFEDE5FF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              child: Text('🏆', style: TextStyle(fontSize: 27)),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'IDEIA MAIS VOTADA',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ideia.titulo,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${ideia.votos} ${ideia.votos == 1 ? 'voto' : 'votos'}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IdeiaCard extends StatelessWidget {
  final Ideia ideia;
  final VoidCallback onVotar;
  final VoidCallback onExcluir;

  const _IdeiaCard({
    required this.ideia,
    required this.onVotar,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    ideia.titulo,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  tooltip: 'Excluir ideia',
                  onPressed: onExcluir,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              ideia.descricao,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.black87,
                  ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 19),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    ideia.autor,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const Icon(Icons.favorite_outline, size: 19),
                const SizedBox(width: 6),
                Text(
                  '${ideia.votos} ${ideia.votos == 1 ? 'voto' : 'votos'}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onVotar,
                icon: const Icon(Icons.how_to_vote_outlined),
                label: const Text('VOTAR'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MensagemCentral extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String mensagem;

  const _MensagemCentral({
    required this.icon,
    required this.titulo,
    required this.mensagem,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 70, color: Colors.deepPurple),
            const SizedBox(height: 18),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              mensagem,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
