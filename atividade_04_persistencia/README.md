Atividade com CRUD de contatos usando `sqflite`, funcionando em **Android** e **Web**.

- **Android:** usa o SQLite nativo do sistema. O banco é um arquivo `.db` na pasta de dados do app.
- **Web:** usa `sqflite_common_ffi_web` (SQLite compilado para WebAssembly). O banco fica dentro do navegador (IndexedDB/OPFS).

## Dependências do projeto

No `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.0
  sqflite_common_ffi_web: ^0.4.0
  path: ^1.9.0
```

Instale:

```bash
flutter pub get
```

## Rodando no Android

### O que precisa

- **Android Studio** (ou apenas o Android SDK + command-line tools)
- Licenças do Android aceitas:

  ```bash
  flutter doctor --android-licenses
  ```

- Um destes dispositivos:
  - **Emulador Android** (criado pelo Device Manager do Android Studio), ou
  - **Celular físico** com _Depuração USB_ ativada (Configurações > Opções do desenvolvedor)

### Passos

1. Liste os dispositivos disponíveis:

   ```bash
   flutter devices
   ```

2. Rode o app:

   ```bash
   flutter run -d <id-do-dispositivo>
   ```

   Ou, se houver apenas um dispositivo conectado:

   ```bash
   flutter run
   ```

### Onde fica o banco no Android

Arquivo `contatos.db` em:

```
/data/data/<nome.do.pacote>/databases/contatos.db
```

Para inspecionar: Android Studio > **App Inspection** > **Database Inspector** (com o app rodando em modo debug).

---

## Rodando na Web

### O que precisa

- **Google Chrome** (ou outro navegador compatível, como Edge)
- Os arquivos do SQLite WebAssembly dentro da pasta `web/` (**passo obrigatório, feito uma única vez**).

### Passos

1. Gere os arquivos necessários (`sqlite3.wasm` e `sqflite_sw.js`) na pasta `web/`:

   ```bash
   dart run sqflite_common_ffi_web:setup
   ```

2. Rode o app no Chrome:

   ```bash
   flutter run -d chrome
   ```

> Se o banco apresentar problemas com o web worker no ambiente de desenvolvimento, troque `databaseFactoryFfiWeb` por `databaseFactoryFfiWebNoWebWorker` em `lib/database/banco_de_dados.dart`.

### Onde fica o banco na Web

Não existe arquivo `.db` no disco. Os dados ficam **dentro do navegador**, no IndexedDB/OPFS.

Para inspecionar no Chrome:

1. Abra o DevTools (`F12`)
2. Aba **Application**
3. **Storage > IndexedDB**
