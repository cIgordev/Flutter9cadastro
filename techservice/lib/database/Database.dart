import '../model/ServiceOrder.dart';

class Database {
  // --- INÍCIO DO PADRÃO SINGLETON ---
  // Cria uma instância interna privada
  static final Database _instance = Database._internal();

  // Construtor privado para que ninguém de fora use "new Database()"
  // criando outro objeto
  Database._internal();

  // Sempre que alguém chamar Database(), retorna a mesma instância da memória
  factory Database() => _instance;
  // --- FIM DO PADRÃO SINGLETON ---

  final List<ServiceOrder> serviceOrdersMock = [
    ServiceOrder(
      id: 'OS-2026-001',
      client: 'Lab de Informática 3',
      status: 'Em Andamento',
      desc: 'Manutenção preventiva dos computadores.',
    ),
    ServiceOrder(
      id: 'OS-2026-002',
      client: 'Secretaria Executiva',
      status: 'Aberta',
      desc: 'Configuração de nova sub-rede local.',
    ),
    ServiceOrder(
      id: 'OS-2026-003',
      client: 'Bloco Técnico B',
      status: 'Concluída',
      desc: 'Troca de switch e testes de patch panel.',
    ),
  ];

  // O método getOrders encapsula os dados mockados e retorna a lista convertida
  List<ServiceOrder> getOrders() {
    return serviceOrdersMock;
  }

  void addOrder(ServiceOrder order) {
    serviceOrdersMock.add(order);
  }
}
