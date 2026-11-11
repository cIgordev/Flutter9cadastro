import 'package:flutter/material.dart';

import '../database/Database.dart';
import '../model/ServiceOrder.dart';
import 'cadastro_order_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Sempre retorna a mesma instância (Singleton)
  final Database _db = Database();

  // Dados simulados para preencher a lista
  List<ServiceOrder> _serviceOrders = [];

  @override
  void initState() {
    super.initState();
    // Carrega os dados iniciais do getOrders();
    _serviceOrders = _db.getOrders();
  }

  // Ícone e cor de acordo com o status da ordem
  Widget _statusIcon(String status) {
    switch (status) {
      case 'Em Andamento':
        return const Icon(Icons.pending, color: Colors.orange);
      case 'Concluída':
        return const Icon(Icons.check_circle, color: Colors.green);
      default:
        return const Icon(Icons.error_outline, color: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TechService Home'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Painel de Atividades',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Olá, Técnico. Veja os seus chamados para hoje:',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _serviceOrders.length,
                itemBuilder: (context, index) {
                  final os = _serviceOrders[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: _statusIcon(os.status),
                      title: Text(
                        '${os.id} - ${os.client}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        os.desc,
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          os.status,
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Abre o modal de cadastro e aguarda o retorno do objeto
          final ServiceOrder? novaOS = await showModalBottomSheet<ServiceOrder>(
            context: context,
            isScrollControlled: true, // Permite que o modal suba além da metade da tela
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => const CadastroOrderModal(),
          );

          // Se o usuário preencheu e salvou (não cancelou voltando a tela)
          if (novaOS != null) {
            debugPrint('Nova OS recebida: ${novaOS.client}');

            setState(() {
              _db.addOrder(novaOS);
              // Atualiza a lista local
              _serviceOrders = _db.getOrders();
            });

            // Feedback para usuário
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ordem de serviço salva com sucesso!'),
              ),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
