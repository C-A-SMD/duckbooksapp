Adicionar o SDK do Firebase

Use o Swift Package Manager para instalar e gerenciar as dependências do Firebase.

No Xcode, com seu projeto de app aberto, navegue até File > Add Packages
Quando solicitado, insira o URL do repositório do SDK do Firebase para iOS:
https://github.com/firebase/firebase-ios-sdk
Selecione a versão do SDK que você quer usar.
Recomendamos que você use a versão padrão do SDK, que também é a mais recente, mas você poderá usar uma versão anterior se for necessário.

Escolha as bibliotecas do Firebase que você quer usar.
Não deixe de adicionar FirebaseAnalytics. Para o Analytics sem o recurso de coleção de IDFAs, adicione FirebaseAnalyticsWithoutAdId.

Depois de clicar em Finish, o Xcode começará a resolver e fazer o download das suas dependências automaticamente em segundo plano.