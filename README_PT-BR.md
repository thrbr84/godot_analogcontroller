# Godot - Analog Controller (Controle Analógico)

- Desenvolvido para a Godot 3.2
- [English documentation](README.md)

Um controle analógico virtual para as seguintes direções:
- 360º (Vector2), 
- 2_H (Horizontal), 
- 2_V (Vertical), 
- 4 (esquerda, direita, cima, baixo)
- 8 (esquerda["cima, baixo"], direita["cima, baixo"], cima, baixo)

----------

### Demonstração (PT-BR)
- https://www.youtube.com/watch?v=plHDdyC_suc

[![Video com a explicação](https://img.youtube.com/vi/plHDdyC_suc/0.jpg)](https://www.youtube.com/watch?v=plHDdyC_suc)

----------

##### Exemplo
No projeto exemplo, mostro dois exemplos de como utilizar em um player com movimentos em Vetor2, e com movimentos em direções pré-definidas (alias).

----------

##### Configurar o Addon
- Faça download do arquivo [addon/analog.zip](addon/analog_controller.zip)
- Coloque na pasta "addons" do seu projeto
- Acesse as Configurações do Projeto > Plugin e habilite o plugin "AnalogController"

----------

##### Sinais

O AnalogController emite três sinais!

- analogChange(force, pos)
- analogPressed
- analogRelease

Para o sinal ```analogChange(force, pos)``` o parâmetro "force" é um valor(float) retornado de "0.0 à 1.0" para o tipo 360º

*Para 2,4 e 8 (direções em alias) o force retorna um Vector2 normalizado() já com a força do analógico calculada! 
E no parâmetro "pos" é retornado a alias da posição... "direita, esquerda, etc..."

----------

##### Configurações do Node


- ```(boolean) isDynamicallyShowing``` = O controle analógico deve aparecer dinamicamente, ou fixo na tela
- ```(typesAnalog) typeAnalogic``` = DIRECTION_2_H, DIRECTION_2_V, DIRECTION_4, DIRECTION_8, DIRECTION_360
- ```(float,0.00,1.0) var smoothClick``` = Tempo para o controle aparecer ao clicar no analógico
- ```(float,0.00,1.0) var smoothRelease``` = Tempo para o controle ficar oculto ao soltar o analógico
- ```(Texture) var bigBallTexture``` = Você pode carregar uma textura de sua preferência para a bolinha maior (base) do analógico
- ```(Texture) var smallBallTexture``` = Você pode carregar uma textura de sua preferência para a bolinha menor do analógico
- ```(Dictionary) directionsResult``` = Aqui você pode definir os apelidos que você quer que retorne em cada direção exceto 360º

----------

### ...
Vai utilizar esse código de forma comercial? Fique tranquilo pode usar de forma livre e sem precisar mencionar nada, claro que vou ficar contente se pelo menos lembrar da ajuda e compartilhar com os amigos, rs. Caso sinta no coração, considere me pagar um cafezinho :heart: -> https://ko-fi.com/thiagobruno

