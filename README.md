# CMOV_app

Aplicativo de captura de movimento que utiliza o MLKit da Google para capturar, desenhar e passar para um backend os dados da captura.
Feito em Dart por Lucas Coimbra da Silva && Leonardo Massuhiro Sato.

## Sobre

Esse projeto tem como objetivo capturar as poses de uma pessoa e passar para o Firebase os dados da captura, com o objetivo final de controlar um robo.
Ele utiliza o MLKit para a captura das poses e o Realtime Database do Firebase para a passagem dos dados para o robo.

## Como utilizar
Instale o projeto (não se esqueça de rodar "flutter pub get" no console!).

Depois de instalado e sem nenhum problemas com os plugins, apenas rode o projeto.
(ATENÇÃO: o projeto não foi testado em celulares IOS.)

Algumas observações:
- O programa foi feito APENAS para celulares;
- O programa funciona apenas em celulares android 12 ou acima (limitação do MLKit);
- Evite trocar de tela enquanto a captura de movimento está sendo efetuada (no caso a captura em tempo real).

Ao iniciar o aplicativo, estarão presentes duas abas na área inferior:
- Captura de pose de fotos (símbulo de imagem);
- Captura de pose em tempo real (símbulo de camera com um +).

Na aba de captura de pose de fotos, você poderá:
- Capturar a pose de uma foto da galeria (ao apertar em "escolher uma foto" ou no símbulo de +, se você descer a tela);
- Capturar a pose de uma foto da camera (ao apertar no símbulo de câmera).

Na aba de captura de pose em tempo real, você poderá:
- Apertar no play (ou na camera) para iniciar a captura;
- Caso esteja capturando, apertar o pause (ou na camera) para parar a captura;

ATENÇÃO: lembrando que não é recomendado mudar de tela ENQUANTO a captura em tempo real estiver rodando.

## Plugins utilizados

- Camera [https://pub.dev/packages/camera];
- Image Picker [https://pub.dev/packages/image_picker];
- Firebase Core & Realtime Database [https://firebase.flutter.dev/];
- MLKit Pose Detection [https://pub.dev/packages/google_mlkit_pose_detection];
- Shimmer (animação de carregando) [https://pub.dev/packages/shimmer].

## Documentação
- MLKit (https://developers.google.com/ml-kit)
- Realtime Database from Firebase (https://firebase.google.com/docs/database/)

## Como foi feito

A captura por foto foi feita com o uso do ImagePicker.

A captura em tempo real foi feita utilizando ImageStream, a qual a imagem gerada por ele (em yuv420 para o android utilizado nos testes) pode ser passada como binário direto para o MLKit, sem precisar converter para uma imagem normal (algo que muitas pessoas não sabem).
Isso evita a dor de cabeça de converter yuv420 para uma imagem normal (que utilizaria código em C para evitar problemas com performance) e evita a preocupação com a performance na conversão (já que ela não ocorre).

Na captura em tempo real há a verificação das poses em 4 threads, sendo possível alterar o número máximo de threads modificando a variável "_poseScanningMaxCount" (4 foi o número que menos afetou a perfomance em comparação com a melhora na fluidez da captura).
