class ServiceOrder {
  final String id;
  final String client;
  final String status;
  final String desc;

  // Construtor padrão
  ServiceOrder({
    required this.id,
    required this.client,
    required this.status,
    required this.desc,
  });

  // Construtor factory para mapear o Map do Dart para o
  // Objeto. Será utilizada mais a frente para fetch em API externa.
  factory ServiceOrder.fromJson(Map<String, String> json) {
    return ServiceOrder(
      id: json['id'] ?? '',
      client: json['client'] ?? '',
      status: json['status'] ?? '',
      desc: json['desc'] ?? '',
    );
  }

  // Sobrescrevendo o toString para facilitar o print no console
  @override
  String toString() =>
      'ServiceOrder(id: $id, client: $client, status: $status)';
}
