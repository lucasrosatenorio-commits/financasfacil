# 💰 FinançasFácil – Código Flutter Completo

App de controle de finanças pessoais com IA integrada (Claude).

---

## 📁 Estrutura do Projeto

```
financasfacil/
├── lib/
│   ├── main.dart                        ← Entrada do app
│   ├── theme.dart                       ← Cores e tema
│   ├── models/
│   │   ├── transaction.dart             ← Modelo de dados
│   │   └── finance_provider.dart        ← Gerenciamento de estado
│   └── screens/
│       ├── dashboard_screen.dart        ← Tela principal
│       ├── add_transaction_screen.dart  ← Adicionar transação
│       └── ai_tip_screen.dart           ← Dica com IA
├── android/
│   └── app/src/main/AndroidManifest.xml
└── pubspec.yaml                         ← Dependências
```

---

## 🛠️ Como Compilar (Para o Freelancer)

### Pré-requisitos
- Flutter SDK 3.x instalado
- Android Studio ou VS Code
- JDK 17+
- Android SDK (API 21+)

### Passos

```bash
# 1. Entre na pasta do projeto
cd financasfacil

# 2. Instale as dependências
flutter pub get

# 3. Adicione o pacote http (necessário para IA)
flutter pub add http

# 4. Teste no emulador
flutter run

# 5. Gere o arquivo para a Play Store
flutter build appbundle --release
```

O arquivo `.aab` gerado estará em:
`build/app/outputs/bundle/release/app-release.aab`

---

## 🔑 Configurar a IA (Claude)

No arquivo `lib/screens/ai_tip_screen.dart`, linha com `headers`:

```dart
headers: {
  'Content-Type': 'application/json',
  'anthropic-version': '2023-06-01',
  'x-api-key': 'SUA_CHAVE_AQUI',  // ← adicionar chave da API
},
```

Obtenha sua chave em: https://console.anthropic.com

---

## 💰 Adicionar AdMob (Anúncios)

1. Crie conta em https://admob.google.com
2. Pegue o `App ID` e substitua no `AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-SEU_ID_AQUI~NUMERO"/>
```
3. Adicione banners nas telas conforme documentação do `google_mobile_ads`

---

## 📱 Funcionalidades do App

- ✅ Dashboard com saldo, receitas e despesas
- ✅ Gráfico de barras dos últimos 6 meses  
- ✅ Gastos por categoria com barras de progresso
- ✅ Meta de gastos personalizável
- ✅ Adicionar e remover transações
- ✅ Dicas personalizadas com Inteligência Artificial (Claude)
- ✅ Dados salvos localmente (offline)
- ✅ Interface escura e moderna

---

## 🚀 Publicar na Play Console

1. Acesse: https://play.google.com/console
2. Crie novo app → Categoria: **Finanças**
3. Faça upload do `app-release.aab`
4. Use os textos do arquivo `Kit_PlayStore_FinancasFacil.docx`
5. Envie para revisão (3–7 dias)

---

## 📞 Suporte
Criado com Claude AI • Junho 2026
