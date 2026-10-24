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


<img width="186" height="398" alt="Picture2" src="https://github.com/user-attachments/assets/c4bbf706-e932-47ac-923d-ae98f950c811" />

Tela de Escolha de Cadastro


<img width="195" height="419" alt="Picture3" src="https://github.com/user-attachments/assets/93efecb5-3826-479d-860d-58298d7ac542" />

Tela de Cadastro


<img width="204" height="440" alt="Picture4" src="https://github.com/user-attachments/assets/8986f597-5b3e-4bfd-9f60-0853648e2b5a" />

Tela de Perfil Profissional


<img width="211" height="454" alt="Picture5" src="https://github.com/user-attachments/assets/7a252b58-ee81-40b9-bcf2-d976f1616a4e" />

Tela de Pesquisa 1


<img width="201" height="428" alt="Picture6" src="https://github.com/user-attachments/assets/ef757cea-9312-406b-87bb-972c8b7a03ad" />

Tela de Perfil do Usuário


<img width="200" height="442" alt="Picture7" src="https://github.com/user-attachments/assets/729ce27b-a741-4310-b2e4-8c9c29a19ebe" />

Tela de Chat Usuário


<img width="192" height="408" alt="Picture8" src="https://github.com/user-attachments/assets/cd739ae0-eaab-4cc8-93ea-c4c59c14ca7a" />

Tela de Configurações


<img width="205" height="431" alt="Picture9" src="https://github.com/user-attachments/assets/1def2201-9bcd-4223-8619-1d99cedf0bc5" />

Tela de Pesquisa 2


<img width="186" height="401" alt="Picture10" src="https://github.com/user-attachments/assets/a55cff75-841d-43de-92ae-170ec6524ca8" />

Tela de Chat
## Status

Projeto acadêmico (TCC).
