# Batalha de Ideias

Aplicativo Flutter + Cloud Firestore baseado na atividade "Batalha de Ideias".

## Funcionalidades

- Cadastrar ideias com título, descrição e autor.
- Salvar as ideias na coleção `ideias` do Cloud Firestore.
- Começar cada ideia com `votos: 0`.
- Visualizar ideias em tempo real.
- Votar em uma ideia usando `FieldValue.increment(1)`.
- Excluir ideias diretamente do Firestore.
- Mostrar automaticamente a ideia mais votada.
- Compartilhar os dados entre usuários/dispositivos conectados ao mesmo Firebase.

## Como abrir no VS Code

1. Extraia o ZIP.
2. Abra a pasta `batalha_de_ideias` no VS Code.
3. Tenha Flutter e Dart instalados.
4. Abra o terminal do VS Code.
5. Execute:

```bash
flutter pub get
```

## Configurar o Firebase

É necessário conectar este projeto a um projeto Firebase seu.

### 1. Instalar o FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

Se necessário, adicione a pasta de executáveis do Dart ao PATH do Windows.

### 2. Fazer login

```bash
firebase login
```

Caso o comando `firebase` não exista, instale o Firebase CLI antes.

### 3. Configurar o projeto

Na raiz deste projeto:

```bash
flutterfire configure
```

Selecione o projeto Firebase e as plataformas desejadas.

Esse comando vai substituir o arquivo:

```text
lib/firebase_options.dart
```

com as configurações reais.

## Criar o Firestore

No Firebase Console:

1. Abra seu projeto.
2. Entre em **Firestore Database**.
3. Crie o banco.
4. Use o modo de teste apenas se isso fizer parte da atividade.
5. A coleção utilizada pelo aplicativo será:

```text
ideias
```

Cada documento terá:

```text
titulo
descricao
autor
votos
```

## Regras de teste

O arquivo `firestore.rules` contém regras abertas para facilitar o teste da atividade.

Para uma aplicação real, NÃO use essas regras abertas. Use autenticação e regras de segurança apropriadas.

## Executar

Para Web:

```bash
flutter run -d chrome
```

Para ver os dispositivos disponíveis:

```bash
flutter devices
```

Depois:

```bash
flutter run
```

## Teste obrigatório da atividade

Abra o aplicativo em dois navegadores ou dispositivos conectados ao mesmo Firebase.

1. Cadastre uma ideia no primeiro.
2. Confira se ela aparece no segundo.
3. Vote nela no segundo.
4. Confira se o número de votos atualiza no primeiro.
5. Feche e abra novamente para confirmar que os dados continuam salvos.

## Estrutura

```text
batalha_de_ideias/
├── lib/
│   ├── models/
│   │   └── ideia.dart
│   ├── screens/
│   │   └── home_screen.dart
│   ├── services/
│   │   └── ideia_service.dart
│   ├── firebase_options.dart
│   └── main.dart
├── firestore.rules
├── pubspec.yaml
└── README.md
```
