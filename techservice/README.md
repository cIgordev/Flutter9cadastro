# TechService – Gestão de Ordens de Serviço

Atividade de **Programação Mobile – Flutter** (Prof. KGe): *Flutter Navigator – Route – Melhorias*.

Continuação do projeto de ordens de serviço (Login → Cadastro de Técnico → Home), agora com:

- Classe de modelo `ServiceOrder` (substitui a lista JSON);
- Classe `Database` no padrão **Singleton**, com `getOrders()` e `addOrder()`;
- `HomeScreen` convertida para **StatefulWidget**;
- **Modal** (`showModalBottomSheet`) para cadastrar uma nova ordem de serviço e atualizar a lista.

## Estrutura

```
lib/
├── main.dart                         # rotas: '/', '/cadastro', '/home'
├── model/
│   └── ServiceOrder.dart             # modelo de dados
├── database/
│   └── Database.dart                 # Singleton + dados mockados
└── screens/
    ├── login_screen.dart
    ├── cadastro_tecnico_screen.dart
    ├── cadastro_order_modal.dart     # modal de nova OS
    └── home_screen.dart              # lista + floating button
```

## Como rodar

Esta pasta contém o código (`lib/`) e o `pubspec.yaml`. Para gerar as pastas de plataforma (android, ios, etc.):

```bash
flutter create .
flutter pub get
flutter run
```

> O `flutter create .` não sobrescreve o `lib/` nem o `pubspec.yaml` existentes.

---

## 1. Construtor padrão × construtor factory

### Construtor padrão (generativo)

```dart
ServiceOrder({
  required this.id,
  required this.client,
  required this.status,
  required this.desc,
});
```

- **Sempre cria uma nova instância** da classe.
- Inicializa os atributos diretamente (`this.id`, `this.client`...).
- Não pode ter `return` e não pode devolver outro tipo de objeto.
- Só existe um construtor padrão sem nome por classe (os demais precisam ter nome, como `ServiceOrder.fromJson`).

### Construtor factory

```dart
factory ServiceOrder.fromJson(Map<String, String> json) {
  return ServiceOrder(
    id: json['id'] ?? '',
    client: json['client'] ?? '',
    status: json['status'] ?? '',
    desc: json['desc'] ?? '',
  );
}
```

- Usa a palavra-chave `factory` e **precisa retornar** um objeto (`return`).
- **Não obrigatoriamente cria uma nova instância**: pode devolver uma instância já existente (cache/Singleton) ou até uma instância de um **subtipo**.
- Pode executar lógica antes de criar o objeto (validar, converter, aplicar valores padrão).
- **Não tem acesso a `this`**, pois o objeto ainda não existe quando ele começa a executar.
- Não pode inicializar atributos `final` diretamente; ele delega para outro construtor.

### Resumo comparativo

| Característica | Construtor padrão | Construtor factory |
|---|---|---|
| Palavra-chave | nenhuma | `factory` |
| Cria nova instância sempre? | Sim | Não necessariamente |
| Usa `return`? | Não | Sim, obrigatório |
| Acesso a `this` | Sim (initializing formals) | Não |
| Pode retornar um subtipo | Não | Sim |
| Pode devolver instância em cache | Não | Sim |
| Uso típico | Criar o objeto a partir dos valores | Converter dados, aplicar lógica, reaproveitar instância |

### Quando utilizar cada um?

**Construtor padrão** – quando você já tem todos os valores e só precisa montar o objeto. É o caso de `ServiceOrder(id: ..., client: ..., ...)` no modal e no mock do `Database`.

**Construtor factory** – quando criar o objeto exige mais do que atribuir valores:

1. **Converter dados externos** (JSON/Map → objeto), como em `ServiceOrder.fromJson`. Será usado quando a lista vier de uma API real. O `?? ''` garante um valor padrão caso a chave não exista.
2. **Singleton / cache**, quando se quer devolver sempre a mesma instância, como em `factory Database() => _instance;`.
3. **Retornar subtipos** conforme uma condição (por exemplo, `Shape('circle')` devolvendo um `Circle`).
4. **Validar ou normalizar** os dados antes de criar o objeto.

---

## 2. Singleton em Dart

### O que é

**Singleton** é um padrão de projeto (*design pattern*) criacional que garante que uma classe tenha **uma única instância** durante toda a execução da aplicação, oferecendo um ponto de acesso global a ela. Qualquer parte do app que "criar" a classe receberá sempre o mesmo objeto na memória.

### Quando usar

- Acesso a banco de dados ou serviço de API (uma única "conexão" ou fonte de dados);
- Configurações globais do app;
- Cache, logger, gerenciador de sessão.

No TechService, `Database` é Singleton para que **todas as telas enxerguem a mesma lista de ordens**. Se cada tela criasse seu próprio `Database`, uma ordem adicionada em uma tela não apareceria nas outras.

### Como implementar em Dart

O Dart facilita o padrão por causa dos **construtores factory**, em 3 passos:

```dart
class Database {
  // 1) Instância única, privada, criada uma única vez
  static final Database _instance = Database._internal();

  // 2) Construtor privado (nome começa com "_"): ninguém de fora consegue criar outro objeto
  Database._internal();

  // 3) Factory que sempre devolve a mesma instância
  factory Database() => _instance;
}
```

Teste:

```dart
final a = Database();
final b = Database();
print(identical(a, b)); // true → são o MESMO objeto
```

### Pontos importantes

- `static final` é inicializado de forma *lazy*: a instância só é criada na primeira vez que `_instance` é acessado.
- O construtor privado `Database._internal()` impede `new` de fora do arquivo/biblioteca.
- O `factory Database()` permite usar a sintaxe normal `Database()`, sem precisar de `Database.getInstance()`.

### Vantagens e cuidados

| Vantagens | Cuidados |
|---|---|
| Estado compartilhado entre telas | Estado global dificulta testes |
| Economia de memória (um só objeto) | Pode esconder dependências entre classes |
| Acesso simples e padronizado | Os dados se perdem ao fechar o app (aqui são só mock em memória) |

Em projetos maiores, costuma-se combinar com injeção de dependência (por exemplo, `get_it` ou `Provider`) para facilitar testes.

---

## 3. Finalidade do `setState` (linha 134)

Trecho do código:

```dart
setState(() {                           // ← linha 134
  _db.addOrder(novaOS);
  // Atualiza a lista local
  _serviceOrders = _db.getOrders();
});
```

### O que está acontecendo na linha 134?

Depois que o modal fecha e devolve a nova ordem (`novaOS`), a linha 134 chama o `setState`. Dentro dele:

1. `_db.addOrder(novaOS)` adiciona a nova ordem na lista do `Database` (Singleton);
2. `_serviceOrders = _db.getOrders()` atualiza a lista usada pela tela;
3. Ao final da função, o Flutter marca o widget como "sujo" e **reexecuta o método `build()`**, redesenhando a `ListView` com o novo item.

### Qual a finalidade do `setState`?

O `setState` serve para **avisar o framework de que o estado interno de um `StatefulWidget` mudou** e que a interface precisa ser reconstruída para refletir essa mudança.

- Sem `setState`, a variável até mudaria na memória, mas **a tela continuaria igual**, e a nova ordem só apareceria se a tela fosse reconstruída por outro motivo.
- Só existe em `State<T>` (por isso foi necessário trocar `HomeScreen` de **Stateless** para **Stateful**). Um `StatelessWidget` não tem estado mutável nem `setState`.
- O Flutter não redesenha a tela inteira: ele reconstrói a árvore de widgets daquele `State` e atualiza apenas o que mudou na renderização.

### Boas práticas

- Colocar dentro do `setState` somente a alteração de estado (rápida e síncrona);
- Nunca chamar `setState` dentro do `build()` (gera loop de reconstrução);
- Nunca chamar `setState` depois de o widget ser descartado (`dispose`); por isso há o `if (!context.mounted) return;` após o `await`.
