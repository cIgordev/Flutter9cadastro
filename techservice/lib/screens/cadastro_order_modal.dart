import 'package:flutter/material.dart';
import '../model/ServiceOrder.dart';

class CadastroOrderModal extends StatefulWidget {
  const CadastroOrderModal({super.key});

  @override
  State<CadastroOrderModal> createState() => _CadastroOrderModalState();
}

class _CadastroOrderModalState extends State<CadastroOrderModal> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para capturar o texto digitado
  final _clientController = TextEditingController();
  final _descController = TextEditingController();

  // Status inicial padrão
  String _statusSelecionado = 'Aberta';

  @override
  void dispose() {
    _clientController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Padding dinâmico para o teclado não cobrir os campos
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: bottomInset + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Nova Ordem de Serviço',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Campo Cliente
              TextFormField(
                controller: _clientController,
                decoration: const InputDecoration(
                  labelText: 'Cliente / Local',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira o cliente.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo Descrição
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descrição do Problema/Serviço',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira uma descrição.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Seletor de Status (Dropdown)
              DropdownButtonFormField<String>(
                initialValue: _statusSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Status Inicial',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.info_outline),
                ),
                items: ['Aberta', 'Em Andamento', 'Concluída']
                    .map(
                      (status) =>
                          DropdownMenuItem(value: status, child: Text(status)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _statusSelecionado = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),

              // Botão Salvar
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Criando o objeto com IDs fictícios/gerados temporariamente
                    final novaOrdem = ServiceOrder(
                      id: 'OS-2026-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}',
                      client: _clientController.text,
                      status: _statusSelecionado,
                      desc: _descController.text,
                    );

                    // Fecha o modal e retorna a nova ordem para quem chamou
                    Navigator.pop(context, novaOrdem);
                  }
                },
                child: const Text(
                  'Salvar Ordem',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
