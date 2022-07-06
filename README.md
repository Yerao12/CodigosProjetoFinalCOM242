# CodigosProjetoFinalCOM242
 Códigos do protótipo para o Projeto Final da disciplina COM242 - Sistema Distribuídos

Para a execução do front em Node-RED, basta instalar ele globalmente em sua máquina utilizando o comando:
npm install -g node-red, e ele abrirá no endereço localhost:1880.

Após isto, deve adicionar ao ambiente do Node-RED o conjunto de nós Dashboard, seguindo o começo deste tutorial:
https://imasters.com.br/desenvolvimento/node-red-construindo-dashboard-parte-01-instalacao-e-configuracao

Finalizando, basta importar o arquivo flows.json que se localiza no repositório, para seu ambiente obter todos os nós já configurados (ressalva para a parte de obtenção de logs e a execução do scipt python em segundo plano).

Estas partes citadas com ressalva precisam de uma maior configuração, sendo necessário configurar o caminho do script python no nó exec e o caminho dos logs (a mesma pasta do script) gerados na função de concatenação do nome do log. 
