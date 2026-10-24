# Terapia Mais

Aplicativo mobile desenvolvido como Trabalho de Conclusão de Curso (TCC), que conecta terapeutas e pacientes para disponibilizar atendimento online a quem não consegue ir até o consultório.

O projeto é dividido em dois aplicativos:

- **Aplicativo do paciente** (`terapa_clientes_v1`)
- **Aplicativo do terapeuta** (`terapia_mais_4terapeutas`)

## Funcionalidades

- Chat entre terapeuta e paciente integrado ao banco de dados, com as mensagens salvas e sincronizadas
- Dois aplicativos separados, cada um com a experiência pensada para seu tipo de usuário

## Tecnologias

- [Flutter](https://flutter.dev/)
- [Dart](https://dart.dev/)
- [Firebase](https://firebase.google.com/)

## Estrutura do repositório

```
Terapia-Mais/
├── terapa_clientes_v1/          # app do paciente
└── terapia_mais_4terapeutas/    # app do terapeuta
```

## Como executar

1. Instale o [Flutter SDK](https://docs.flutter.dev/get-started/install)
2. Clone o repositório:
   ```bash
   git clone https://github.com/Lookeon/Terapia-Mais.git
   ```
3. Entre na pasta do app que deseja rodar e instale as dependências:
   ```bash
   cd Terapia-Mais/terapia_mais_4terapeutas
   flutter pub get
   ```
4. Conecte um celular Android (com depuração USB) ou abra um emulador e execute:
   ```bash
   flutter run
   ```

Para rodar o app do paciente, use a pasta `terapa_clientes_v1` no passo 3.

> **Firebase:** o projeto depende de um projeto Firebase configurado. Por segurança, os arquivos de configuração (como o `google-services.json`) podem não estar neste repositório, e quem quiser rodar o app deve configurar o próprio projeto no Firebase.

## Minha contribuição

- Idealização do aplicativo
- Construção do chat
- Integração do chat com o banco de dados

## Exemplos visuais

<img width="207" height="440" alt="Picture1" src="https://github.com/user-attachments/assets/b3d4d0a3-bd34-4904-b91e-4129811a57ee" />

Tela de Login


## Status

Projeto acadêmico (TCC).
