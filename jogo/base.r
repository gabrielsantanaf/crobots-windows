/* base.r - ROBO BASE
   Copie, renomeie com seu nome (ex: joao.r) e modifique.

   O que ele faz: fica parado girando o radar. Achou alguem
   no alcance, atira. Levou tiro, foge numa direcao sorteada.

   EXPERIMENTOS (mude UM de cada vez):
   - PASSO = 4 ou 20     radar mais lento / mais rapido
   - FOCO = 0 ou 10      radar mais preciso / mais aberto
   - VELOC = 100         foge rapido, mas nao faz curva
   - dist < 300          so atira perto (da mais dano)
   - grau = grau - PASSO depois de atirar, volta um pouco
   - drive() antes do while, para andar sempre
*/

int PASSO;    /* graus por varredura */
int FOCO;     /* abertura do radar, 0 a 10 */
int VELOC;    /* velocidade da fuga, 0 a 100 */

main()
{
  int grau;
  int dist;
  int antes;

  PASSO = 10;
  FOCO  = 5;
  VELOC = 60;

  grau  = 0;
  antes = damage();

  while (1)
  {
    dist = scan(grau, FOCO);

    if (dist > 0 && dist <= 700)
      cannon(grau, dist);
    else
      grau = grau + PASSO;

    if (grau >= 360)
      grau = 0;

    if (damage() > antes)
    {
      fugir();
      antes = damage();
    }
  }
}

fugir()
{
  int rumo;
  rumo = rand(360);
  drive(rumo, VELOC);
  return (0);
}
