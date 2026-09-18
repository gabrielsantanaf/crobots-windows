# CROBOTS — Manual (tradução para português)

**CROBOTS** (lê-se "cê-robôs") é um jogo baseado em programação de computadores.

© 1985–2013 Tom Poindexter. Distribuído sob a **GNU General Public License, versão 2**.
Versão HTML original formatada por Neil Fraser (21 de novembro de 2013).
Tradução para o português do Brasil — livre para redistribuir sob os mesmos termos da GPLv2.

> **Nota da tradução:** o manual original foi escrito para MS-DOS em 1985. Onde o texto fala de `A>`, `prn:` ou Ctrl-Break, foram inseridas notas indicando o equivalente no Linux/macOS (fork mantido em `github.com/troglobit/crobots`).

---

## Sumário

1. [Licença e isenção de garantia](#1-licença-e-isenção-de-garantia)
2. [Introdução](#2-introdução)
3. [Tipos de jogo](#3-tipos-de-jogo)
4. [Executando o CROBOTS](#4-executando-o-crobots)
5. [Parâmetros do jogo](#5-parâmetros-do-jogo)
6. [A CPU do CROBOTS](#6-a-cpu-do-crobots)
7. [O compilador C do CROBOTS](#7-o-compilador-c-do-crobots)
8. [Biblioteca de funções intrínsecas](#8-biblioteca-de-funções-intrínsecas)
9. [Estrutura de um programa CROBOTS](#9-estrutura-de-um-programa-crobots)
10. [Arquitetura da CPU](#10-arquitetura-da-cpu)
11. [Notas de implementação](#11-notas-de-implementação)

---

## 1. Licença e isenção de garantia

CROBOTS é copyright 1985–2013 de Tom Poindexter, distribuído sob os termos da GNU General Public License, versão 2.

**Isenção de garantia:** o software e o manual são fornecidos "como estão", sem garantia de qualquer natureza, expressa ou implícita, incluindo — mas não se limitando a — as garantias implícitas de comercialização e de adequação a um propósito. Quem usa este software e este manual assume todos os riscos.

---

## 2. Introdução

### 2.1. Descrição

Diferente dos jogos de fliperama, que exigem que um humano controle algum objeto em tempo real, no CROBOTS **toda a estratégia precisa estar pronta antes de a partida começar**. A estratégia é condensada em um programa em linguagem C que você projeta e escreve. Seu programa controla um robô cuja missão é procurar, rastrear e destruir os outros robôs, cada um rodando um programa diferente.

Todos os robôs têm equipamento idêntico, e até quatro podem competir ao mesmo tempo. O CROBOTS rende mais quando jogado entre várias pessoas, cada uma refinando o próprio programa e depois colocando programa contra programa.

O CROBOTS é composto por um compilador C, um computador virtual e um display do campo de batalha (apenas gráficos de texto, monocromático ou colorido). O compilador aceita um subconjunto limitado — mas útil — da linguagem C. Os programas contam com funções de hardware para varrer o campo em busca de oponentes, ligar e desligar o motor, disparar o canhão etc. Depois de compilados e carregados em robôs separados, a batalha é observada: robôs se movendo, mísseis voando e explodindo, e informações de status aparecem na tela em tempo real.

### 2.2. Público-alvo

O CROBOTS deve interessar a programadores (especialmente os que acham que escrevem os "melhores" programas), a entusiastas de jogos de computador, a quem quer aprender a linguagem C e a quem tem curiosidade sobre projeto de compiladores e interpretadores de máquina virtual.

### 2.3. Requisitos de máquina e software (texto original, era DOS)

- IBM-PC ou compatível MS-DOS que use chamadas de vídeo INT 10H
- 192 KB de RAM
- DOS 2.0 ou superior
- Uma unidade de disco
- Display monocromático ou CGA
- Um editor de texto

> **Nota da tradução:** no fork moderno, os requisitos são um sistema tipo Unix (Linux com glibc ou musl, FreeBSD, DragonflyBSD, macOS, OmniOS), `ncurses` e um terminal. Para compilar do código-fonte você também precisa de `build-essential`, `autoconf`, `automake`, `pkg-config`, `libncurses-dev`, `bison` e `flex`.

### 2.4. Interface com o usuário

O CROBOTS não usa menus, janelas, pop-ups nem qualquer outro recurso de interface amigável. Como a ênfase está em projetar e escrever os programas de controle dos robôs, o CROBOTS é iniciado pela linha de comando, como se inicia um compilador.

---

## 3. Tipos de jogo

**Partida única (single play).** Roda uma batalha usando o display de tela cheia em tempo real. É o comportamento padrão.

**Série de partidas (match play).** Roda várias batalhas e imprime apenas o nome do vencedor ao final de cada uma. Serve para avaliar o desempenho *médio* dos programas. Pode consumir várias horas de processamento, dependendo do número de partidas e do limite de ciclos de CPU — dá para deixar rodando de madrugada.

> **Nota didática:** para um campeonato justo, use sempre a série de partidas. Uma batalha isolada tem muito ruído — a posição inicial sorteada pesa mais que a estratégia.

---

## 4. Executando o CROBOTS

### 4.1. Opções de linha de comando

```
crobots [opções] programa-robô-1 [programa-robô-n] [>arquivo]
```

| Opção | Efeito |
|---|---|
| `-c` | Apenas compila, e produz o código assembler da máquina virtual e as tabelas de símbolos. |
| `-d` | Compila um programa e ativa o rastreamento passo a passo em nível de máquina. |
| `-mxxx` | Roda uma série de partidas, onde `xxx` é o número de partidas. **Sem espaço** entre `-m` e o número. Sem essa opção, roda uma partida com o campo de batalha em tempo real. |
| `-lxxx` | Limita o número de ciclos de CPU por partida quando `-m` é usado. **Sem espaço** entre `-l` e o número. O padrão é 500.000 ciclos quando `-m` está presente. |
| *programas* | **Obrigatório.** Nome dos arquivos-fonte. Até quatro arquivos. Se apenas um for informado, ele é "clonado", de modo que dois robôs rodando o mesmo programa competem entre si. Qualquer nome serve, mas por convenção use a extensão `.r`. |
| `>arquivo` | Redirecionamento para guardar a listagem de compilação (`-c`) ou o resultado das partidas (`-m`). |

### 4.2. Exemplos

Assistir a três robôs competindo, com display completo:

```
crobots robot1.r robot2.r robot3.r
```

Compilar um robô e salvar a listagem:

```
crobots -c robot1.r > robot1.lst
```

Depurar um robô (obtenha antes a listagem assembler, como no exemplo acima):

```
crobots -d robot1.r
```

Rodar 50 partidas, limitando o total de ciclos a 200.000, e salvar o resultado:

```
crobots -m50 -l200000 robot1.r robot2.r > resultado
```

---

## 5. Parâmetros do jogo

### 5.1. O campo de batalha

O campo é um quadrado de **1.000 × 1.000 metros**, cercado por um muro — um robô que bate no muro sofre dano.

- Canto inferior esquerdo: `x = 0`, `y = 0`
- Canto superior direito: `x = 999`, `y = 999`

O sistema de direções está orientado assim:

| Graus | Direção |
|---|---|
| 0 | leste (direita) |
| 90 | norte (cima) |
| 180 | oeste (esquerda) |
| 270 | sul (baixo) |

Um grau abaixo do leste é 359.

### 5.2. Ataque

As armas ofensivas são o **canhão** e o **scanner**.

O canhão tem alcance de **700 metros**. O número de mísseis é ilimitado, mas o tempo de recarga limita a **dois mísseis no ar** simultaneamente. O canhão fica numa torre independente, então atira em qualquer direção de 0 a 359 graus, não importa para onde o robô esteja indo.

O scanner é um dispositivo óptico que varre instantaneamente qualquer direção de 0 a 359 graus, com resolução máxima de ±10 graus. Isso permite varrer o campo rapidamente em baixa resolução e depois usar a resolução máxima para localizar o oponente com precisão.

### 5.3. Defesa

As únicas defesas são o **motor** e os **registradores de status**.

O motor pode ser acionado em qualquer direção de 0 a 359 graus, com velocidade de 0 a 100% da potência. Existem fatores de aceleração e desaceleração. Velocidade 0 desliga o motor. **Curvas só podem ser feitas a 50% de velocidade ou menos**, em qualquer direção. O motor pode ser acionado a qualquer momento, e é necessário na ofensiva quando o alvo está além dos 700 metros de alcance do canhão.

Os registradores de status dão retorno ao robô: percentual de dano, posição atual em x e y, e velocidade atual.

### 5.4. Destruindo oponentes

Um robô é considerado morto quando o dano chega a **100%**. O dano é aplicado assim:

| Dano | Causa |
|---|---|
| 2% | Colisão com outro robô (ambos sofrem dano) ou com o muro. A colisão também desliga o motor e zera a velocidade. |
| 3% | Míssil explodindo dentro de um raio de 40 metros. |
| 5% | Míssil explodindo dentro de um raio de 20 metros. |
| 10% | Míssil explodindo dentro de um raio de 5 metros. |

O dano é cumulativo e não pode ser reparado. Porém, o robô **não perde nenhuma capacidade** com dano alto: um robô com 99% de dano se move e atira exatamente como um robô intacto.

### 5.5. O display

Cada bloco de status mostra o nome do arquivo do robô, o dano sofrido, a direção atual do scanner, a velocidade e o rumo. Na tela, os robôs são representados por `1`, `2` etc., conforme a posição do bloco de status. O número de ciclos de CPU decorridos aparece abaixo dos blocos.

O programa pode ser interrompido a qualquer momento com **Ctrl-Break**.

> **Nota da tradução:** no Linux, use **Ctrl-C**. E maximize a janela do terminal antes de rodar — o display é ncurses, e janela pequena corta o campo.

---

## 6. A CPU do CROBOTS

A CPU do robô é um computador simples, **orientado a pilha**. Ela opera em velocidade bastante baixa (num PC 8088 de 4,77 MHz com dois robôs rodando, a média era de 270 instruções por segundo — 0,00027 MIPS).

- Palavra de **32 bits**, permitindo inteiros de −2.147.483.648 a 2.147.483.647
- Espaço máximo de código: **1.000 instruções**, todas do mesmo tamanho
- Pilha máxima: **500 palavras**, usada para dados e para chamadas/retornos de função

A pilha cresce para cima no uso de dados e para baixo (a partir do fim) nas chamadas de função. Cada chamada consome três palavras, liberadas no retorno. As duas regiões são controladas por ponteiros internos separados.

Se o ponteiro de dados e o de chamada/retorno colidem, ocorre **estouro de pilha**. Nesse caso o robô é reiniciado a partir da função `main`, com a pilha zerada.

---

## 7. O compilador C do CROBOTS

### 7.1. Descrição

O compilador aceita um subconjunto limitado de C. Não há compilação separada — todos os módulos do programa devem estar em **um único arquivo**. Não há pré-processador (`#define`, `#include` etc.). Identificadores são significativos até **7 caracteres**, embora você possa usar nomes mais longos. O código de máquina gerado é carregado na CPU do robô e **não pode ser salvo**.

### 7.2. O que NÃO existe em relação ao C padrão

Ausentes: ponto flutuante, `struct`, `union`, **ponteiros**, inicializadores, **arrays**, dados do tipo caractere, `typedef`, `for`, `do..while`, `switch..case`, `break`, `continue`, `goto` e rótulos, operador ternário e operador vírgula, constantes em octal e hexadecimal, parâmetros em `main()` e todas as diretivas de pré-processador.

> **Nota didática:** essa lista é importante para quem vai usar o CROBOTS em sala. O que sobra — `int`, `if/else`, `while`, funções, expressões — é exatamente o conteúdo das primeiras semanas de uma disciplina de introdução a C. Struct e ponteiro **não** são exercitáveis aqui.

### 7.3. A linguagem do CROBOTS

Os recursos presentes são perfeitamente adequados para escrever programas de controle de robô. `if..else`, `while` e chamadas de função podem ser usados livremente. A avaliação completa de expressões também existe, de forma que construções como esta são legais:

```c
if ((x = func1(y, 1, ++z, func2(c))) > 0)
  a = 0;
else
  a = x;
```

`if` e `while` podem ser aninhados, e **recursão é suportada**. Variáveis declaradas fora de uma função têm escopo global; declaradas dentro, são locais àquela função.

**Palavras-chave e construções reconhecidas:**

| Categoria | Elementos |
|---|---|
| Comentários | `/* ... */` — não podem ser aninhados |
| Constantes | dígitos decimais, opcionalmente precedidos de `-` |
| Declarações | `int`, `long` (igual a `int`), `auto` (escopo padrão, opcional), `register` (aceito, mas ignorado) |
| Controle | `if (expr) CMD else CMD` |
| Iteração | `while (expr) CMD` |
| Retorno | `return`, `return expr` |
| Atribuição | `=` `>>=` `<<=` `+=` `-=` `*=` `/=` `%=` `&=` `^=` `\|=` |
| Bit a bit | `>>` `<<` `&` `!` `~` `^` `\|` |
| Lógicos | `&&` `\|\|` `<=` `>=` `==` `!=` `<` `>` |
| Aritméticos | `-` `+` `*` `/` `%` |
| Incremento | `++` e `--` (prefixados — ver observação abaixo) |
| Diversos | `;` `{ }` `,` `( )` |

Precedência e ordem de avaliação são as mesmas do K&R.

**Desvios principais em relação ao K&R:**

1. Variáveis locais **não precisam ser declaradas** antes do uso — qualquer variável não declarada vira local por padrão.
2. `var++` e `var--` são reconhecidos, mas o resultado é idêntico à forma prefixada (`++var`).
3. Os nomes das funções intrínsecas são reservados.

### 7.4. Limites do compilador

- Funções definidas: **64**
- Variáveis locais por função: **64**
- Variáveis externas: **64**
- Nível de aninhamento de `if`: **16**
- Nível de aninhamento de `while`: **16**

### 7.5. Mensagens de erro e aviso

O compilador **não tem recuperação de erro** e para no primeiro problema encontrado. Avisos não interrompem a compilação.

**Erros:**

| Mensagem original | Significado |
|---|---|
| `syntax error` | Sintaxe C inválida; um indicador aponta para a entrada não reconhecida. |
| `instruction space exceeded` | O compilador tentou gerar mais de 1.000 instruções de máquina. |
| `symbol pool exceeded` | Estourou a tabela de símbolos de variáveis locais, externas ou de funções. |
| `function referenced but not found` | Foi chamada uma função que não está definida no arquivo nem é intrínseca. |
| `main not defined` | O arquivo não definiu a função `main()`. |
| `function definition same as intrinsic` | Foi definida uma função com nome de função intrínseca (nomes reservados). |
| `if nest level exceeded` | Mais de 16 `if` aninhados. |
| `while nest level exceeded` | Mais de 16 `while` aninhados. |
| `yacc stack overflow` | O parser estourou, provavelmente por expressões complexas ou aninhamento extremo. |

**Avisos:**

| Mensagem original | Significado |
|---|---|
| `unsupported initializer` | Declarações não podem incluir inicializador. |
| `unsupported break` | Um `break` foi encontrado e ignorado. |
| `n postfix operators` | Operadores pós-fixados foram convertidos para a forma prefixada. |
| `n undeclared variables` | Uma ou mais variáveis foram declaradas implicitamente. |
| `code utilization: n%` | Percentual do espaço de instruções que foi ocupado. |

---

## 8. Biblioteca de funções intrínsecas

Essas funções dão o controle em nível de máquina e algumas operações aritméticas. Elas **não consomem espaço de código nem da pilha de dados**, exceto pelas três palavras da sequência de chamada/retorno. Nenhuma "linkagem" explícita é necessária.

### `scan(grau, resolução)`

Aciona o scanner na direção e resolução indicadas. Retorna **0** se nenhum robô está no alcance da varredura, ou um **inteiro positivo** representando a distância até o robô mais próximo.

`grau` deve ficar entre 0 e 359; fora disso é forçado ao intervalo por uma operação de módulo 360, e tornado positivo se necessário. `resolução` controla a sensibilidade, até ±10 graus.

```c
alcance = scan(45, 0);    /* varre exatamente 45 graus, sem variação */
alcance = scan(365, 10);  /* varre a faixa de 355 a 15 graus */
```

### `cannon(grau, alcance)`

Dispara um míssil na direção e distância indicadas. Retorna **1** (verdadeiro) se o míssil foi disparado, ou **0** (falso) se o canhão está recarregando. `grau` é forçado ao intervalo 0–359 como em `scan()`. `alcance` pode ser de 0 a 700 — valores maiores são truncados para 700.

```c
grau = 45;                              /* escolhe uma direção para testar */
if ((alcance = scan(grau, 2)) > 0)      /* vê se tem alvo ali */
  cannon(grau, alcance);                /* dispara */
```

### `drive(grau, velocidade)`

Aciona o motor na direção e velocidade indicadas. `grau` é forçado ao intervalo 0–359. `velocidade` é um percentual, com 100 como máximo. Velocidade 0 desliga o motor. **Mudanças de direção só acontecem abaixo de 50% de velocidade.**

```c
drive(0, 100);   /* segue para o leste, velocidade máxima */
drive(90, 0);    /* para o movimento */
```

### `damage()`

Retorna o dano acumulado. Não recebe argumentos; devolve o percentual de 0 a 99. (100% significa robô destruído — portanto, não rodando mais.)

```c
d = damage();        /* salva o estado atual */
/* ... outras instruções ... */
if (d != damage())   /* compara com o estado anterior */
{
  drive(90, 100);    /* levou um tiro — começa a se mover */
  d = damage();      /* atualiza o dano */
}
```

### `speed()`

Retorna a velocidade atual do robô, de 0 a 100. Não recebe argumentos. Atenção: `speed()` **nem sempre é igual ao último `drive()`**, por causa da aceleração e desaceleração.

```c
drive(270, 100);    /* começa a andar para o sul */
/* ... outras instruções ... */
if (speed() == 0)   /* verifica a velocidade */
{
  drive(90, 20);    /* bateu no muro sul, ou em outro robô */
}
```

### `loc_x()` e `loc_y()`

Retornam a posição atual do robô nos eixos x e y, de 0 a 999. Não recebem argumentos.

```c
drive(180, 50);        /* segue rumo ao muro oeste */
while (loc_x() > 20)
  ;                    /* não faz nada até chegar perto */
drive(180, 0);         /* para */
```

### `rand(limite)`

Retorna um número aleatório entre 0 e `limite`, até 32767.

```c
grau = rand(360);          /* escolhe um ponto de partida aleatório */
alcance = scan(grau, 0);   /* e varre */
```

### `sqrt(número)`

Retorna a raiz quadrada. O número é tornado positivo se necessário.

```c
x = x1 - x2;                      /* fórmula clássica da distância */
y = y1 - y2;                      /* entre os pontos (x1,y1) e (x2,y2) */
distancia = sqrt((x*x) - (y*y));
```

### `sin(grau)`, `cos(grau)`, `tan(grau)`, `atan(razão)`

Funções trigonométricas. `sin()`, `cos()` e `tan()` recebem um grau de 0 a 359 e retornam o valor trigonométrico **multiplicado por 100.000**. Essa escala é necessária porque a CPU do CROBOTS só trabalha com inteiros, e os valores trigonométricos ficam entre 0,0 e 1,0.

`atan()` recebe uma razão **já multiplicada por 100.000** e retorna um valor em graus, entre −90 e +90.

**O cálculo só deve ser reduzido à escala real na última operação**, para não perder precisão.

> **Nota didática:** essa escala de 100.000 é a pegadinha que mais derruba iniciante no CROBOTS. Vale explicar em aula antes de qualquer coisa: como não existe `float`, "0,7071" é representado como `70710`.

---

## 9. Estrutura de um programa CROBOTS

### 9.1. Estrutura básica

Programas do CROBOTS não são diferentes de outros programas em C. O programa mínimo consiste em uma função chamada `main`. Além disso, outras funções e variáveis externas podem ser definidas.

### 9.2. Robôs de exemplo

Quatro robôs vêm como exemplo:

| Arquivo | Estratégia |
|---|---|
| `rabbit.r` | Robô simples, que apenas corre pelo campo aleatoriamente. |
| `counter.r` | Usa uma varredura incremental lenta para localizar inimigos. Se move quando é atingido. |
| `rook.r` | Restringe a varredura aos quatro pontos cardeais. Resulta numa varredura muito rápida. |
| `sniper.r` | O mais complexo e devastador dos exemplos. Fica num canto, de modo que só precisa varrer 90 graus. |

As rotinas `distance()` e `plot_course()` do `sniper.r` são bastante úteis — guarde-as para os seus programas. Note também que a rotina principal de varredura dele "volta" alguns graus depois de encontrar e atingir um alvo. Isso serve para pegar robôs tentando fugir na direção oposta à varredura; se o alvo for para o outro lado, o incremento normal o encontra.

> **Nota da tradução:** no fork Linux, os exemplos instalados incluem ainda `target.r`, `jedi12.r` e `ksnipper.r`, e ficam em `/usr/local/share/doc/crobots/examples/`.

---

## 10. Arquitetura da CPU

> Esta seção só é necessária se você for usar o modo de depuração ou tiver curiosidade sobre o interpretador da máquina virtual. Não é preciso lê-la para jogar.

### 10.1. Uso da pilha

A pilha é controlada implicitamente por vários ponteiros, inacessíveis pelas instruções de máquina. A maioria das instruções empilha ou desempilha dados. A pilha é usada de baixo para cima (memória baixa) para dados e armazenamento temporário, e de cima para baixo (memória alta) para salvar ponteiros e o contador de programa nas chamadas de função.

Variáveis externas (globais) ficam no fundo da pilha, e a marca local da `main` começa logo depois delas. Variáveis externas são endereçadas por deslocamento a partir do início da pilha.

Quando uma função é chamada (inclusive a `main`), o ponteiro de pilha é marcado (marca local) e avançado pelo número de variáveis locais daquela função. As locais são endereçadas relativamente à marca local. Todos os cálculos, chamadas e constantes são empilhados e desempilhados conforme a necessidade.

Argumentos são passados **por valor**. O primeiro argumento de uma chamada vira a primeira variável local da função chamada:

```c
main() {                /* main tem três variáveis locais */
  int a, b, c;
  /* ... */
  sub1(a, b/2, c+1);    /* chama sub1 passando argumentos */
  /* ... */
}

sub1(x, y, z)           /* sub1 recebe três parâmetros e */
int x, y, z; {          /* tem uma variável local */
  int result;
  result = x + y + z;
  return (result);
}
```

A `main` aloca três locais na pilha, fixa sua marca local em `a` e coloca o ponteiro temporário logo após as locais. Antes de `sub1()` ser chamada, o valor de `a` é empilhado, seguido do resultado de `b/2` e de `c+1`. Ao ser chamada, `sub1()` fixa sua marca local onde está o valor de `a` — assim `a` é conhecido como `x` dentro de `sub1()`, `b/2` como `y` e `c+1` como `z`. `sub1()` aloca mais uma palavra para `result` e posiciona a marca temporária depois dela.

```
┌────────────┐   ← fim da pilha, memória alta
│retorno main│   ← info de retorno da main
├────────────┤       (frame, ip, marca local)
│retorno sub1│   ← info de retorno de sub1
├────────────┤
│     ↓      │
│            │   ← info de retorno de outras chamadas
│            │       cresce para baixo
│            │
│            │
│            │   ← outras chamadas e expressões
│     ↑      │       crescem para cima
│ expressões │
├────────────┤   ← marca temporária (topo da pilha)
│locais sub1 │
├────────────┤   ← marca local: função sub1
│locais main │
├────────────┤   ← marca local: função main
│            │
│  Externas  │
│            │
└────────────┘   ← início da pilha
```

### 10.2. Lista de ligação (link list)

Lista construída pelo compilador com os nomes e as informações de ligação das funções do programa: posição inicial da função dentro do código, número de parâmetros e número de outras variáveis locais. Não pode ser acessada pelo programa do usuário.

### 10.3. Conjunto de instruções

A CPU tem **10 instruções**, todas ocupando o mesmo espaço, com ou sem operandos.

| Instrução | Função |
|---|---|
| `FETCH deslocamento` | Busca uma palavra do conjunto de variáveis externas ou locais e a empilha. O deslocamento tem o bit alto ligado se for externa. |
| `STORE deslocamento, opcode` | Desempilha os dois itens do topo, aplica o opcode aritmético, empilha o resultado e o armazena na variável referenciada. O resultado fica na pilha. |
| `CONST k` | Empilha uma constante. |
| `BINOP opcode` | Desempilha o topo como `y` e o seguinte como `x`, aplica `(x opcode y)` e empilha o resultado. Opcodes são representações decimais de operadores C como `+`, `/`, `>=`. |
| `FCALL deslocamento` | Chamada de função de alto nível. Empilha a informação de retorno (próximo contador de instrução e marca local atual), define nova marca local e temporária, e desvia para a primeira instrução da função. |
| `RETSUB` | Retorna de uma função, deixando o valor de retorno no topo da pilha. Restaura o conjunto de locais anterior, o contador de instrução e reajusta o frame. O compilador gera código para devolver um valor fictício se a função não retornar um explicitamente. |
| `BRANCH instrução` | Desempilha o topo e desvia para a instrução se o valor for zero. Caso contrário, executa a próxima instrução. |
| `CHOP` | Descarta o topo da pilha. |
| `FRAME` | Salva o ponteiro de topo de pilha atual (marca temporária) em antecipação a um `FCALL`. |
| `NOP` | Nenhuma operação. Marca o fim do código. |

### 10.4. Depuração em nível de máquina

O modo de depuração percorre as instruções de máquina passo a passo. Use apenas se precisar ver o programa executando ou por curiosidade.

Primeiro, obtenha uma listagem completa com a opção `-c`:

```
crobots -c seuprograma.r > listagem.txt
```

Depois inicie com a flag `-d`:

```
crobots -d seuprograma.r
```

Seu robô será posicionado aleatoriamente no campo, e um robô-alvo será colocado no centro (x=500, y=500), para que o programa tenha em quem mirar.

A cada instrução, o interpretador desmonta a instrução e imprime o ponteiro e o valor do topo da pilha (já depois do efeito da instrução). Outras informações também podem aparecer, como buscas na lista de ligação durante chamadas de função.

A cada passo aparece o prompt `d,h,q,<CR>:`:

| Tecla | Efeito |
|---|---|
| `d` | Despeja os conjuntos de variáveis externas e locais, além de informações vitais do robô: coordenadas, rumo, velocidade, dano, e o status dos mísseis disparados. |
| `h` | Simula o robô levando um dano de 10%, para você testar a detecção de dano. |
| `q` | Sai do programa imediatamente. |
| Enter | Continua o passo a passo. |

Todas as respostas devem ser em **letra minúscula**. Consulte a listagem de compilação para os deslocamentos nos conjuntos de variáveis.

---

## 11. Notas de implementação

O CROBOTS é escrito inteiramente em C. A parte do compilador foi desenvolvida com o auxílio dos programas Unix `yacc` e `lex`.

O `yacc` (*yet another compiler-compiler*) recebe uma **gramática**, que descreve a linguagem C do CROBOTS, e produz uma função C conhecida como *parser*. O parser é o coração do compilador, reconhecendo construções C válidas. O `lex` (*lexical analyzer*) recebe uma lista de combinações de tokens e produz uma função C que varre a entrada em busca desses tokens. O parser gerado pelo yacc, `yyparse()`, chama repetidamente o analisador gerado pelo lex, `yylex()`, para processar o programa-fonte.

As rotinas iniciais de display foram desenvolvidas com a biblioteca de tela `curses`.

O código C foi então portado para MS-DOS e recompilado com o compilador Lattice 2.15E, no modelo de memória *small*. As funções de display foram modificadas para usar `int86()`, acessando as funções de posicionamento de cursor da INT 10H do BIOS do IBM-PC.

> **Nota da tradução:** é por isso que o build moderno exige `bison` (substituto GNU do yacc), `flex` (substituto GNU do lex) e `libncurses-dev`. Se algum desses faltar, a compilação quebra exatamente no passo `YACC grammar.c`.

---

*Unix é marca registrada da Bell Telephone Laboratories. MS-DOS é marca registrada da Microsoft, Inc. Lattice é marca registrada da Lattice, Inc. IBM é marca registrada da International Business Machines, Inc.*
