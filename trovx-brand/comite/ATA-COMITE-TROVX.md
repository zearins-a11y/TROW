# Comitê de Marca Trovx — Ata de reunião

**Data:** 2026-09-10
**Participantes:** 4 (Diretor Tipográfico, Head de Estratégia, Diretora de Produto, Head de Marketing de Crescimento)
**Produto:** Trovx — sistema de agentes de IA para pequenos negócios
**Estado atual:** v2 — wordmark com glifo "x" customizado, paleta preto+âmbar, 8 agentes com nomes técnicos

---

## Resumo executivo

**Consenso dos 4 membros:**
- O wordmark atual está funcional mas não memorável
- A paleta preto+âmbar é a decisão certa (vantagem competitiva real vs SaaS azul)
- O maior gap não é visual — é **posicionamento**: Trovx não tem metáfora-âncora em 5 palavras

**Divergência principal:**
- **Estratégia** defende metáfora verbal ("Você opera. Trovx executa.") + módulo chamado "Bridge"
- **Marketing de Crescimento** defende testar com 3 personas antes de refinar mais
- **Tipografia** defende evoluir o wordmark (peso 800 + chanfro no glifo + Instrument Serif)
- **Produto** defende parar de fazer mockups internos e fazer aplicações externas (invoice, push, email)

---

## Posição 1 — Diretor Tipográfico

### Tese
"Wordmark atual é competente, não memorável. Space Grotesk 700 + glifo honesto é execução, não gesto. Em 2026, 'competente' é atestado de óbito."

### Argumentos
- Space Grotesk é o novo Inter — saturado. Marcas premium (Linear, Mercury, Vercel) usam fontes customizadas.
- O glifo "x" com duas linhas cruzadas é honesto mas óbvio. Falta detalhe ótico único.
- Tensão tipográfica via serif pontual é o que separa marcas-manifesto de marcas-produto.

### Proposta concreta: Wordmark v3
| Elemento | Atual | Proposto |
|---|---|---|
| "trov" peso | Space Grotesk **700** | Space Grotesk **800** |
| Glifo "x" | Hastes simétricas em ângulo | **Chanfro de 2px** no vértice superior esquerdo da haste NE |
| Frases de venda | Space Grotesk 600 | **Instrument Serif Italic 400** em `login-quote` e `hero-tagline` |
| Tracktight | -1% | -1% (mantém) |

### Tradeoffs
- Peso 800 pode pesar demais em <24px (mitigação: 700 em favicon)
- 3 fontes no sistema = mais risco de uso indevido (mitigação: regra "serif só em login-quote e hero-tagline")

### Reconhece que está bom
> "Fundir a letra do nome com a letra do produto no glifo do 'x' foi a decisão certa. Preservar e aprofundar, não substituir."

---

## Posição 2 — Head de Estratégia

### Tese
"Trovx é marca competente, não memorável. Produto bom não é marca. Marca é a metáfora que o cliente leva pro café."

### Argumentos
- **Salesforce 2002**: "No software" virou categoria antes deles explicarem o que era CRM
- **Slack 2013**: "Be less busy" ancorou tudo em emoção humana
- **Notion**: "All-in-one workspace" + gesto visual doc-dentro-doc virou linguagem própria

Padrão: marca forte = metáfora verbal de 5 palavras + metáfora visual correspondente. Trovx tem tagline forte mas metáfora visual genérica ("tela cheia com cards").

### Proposta concreta: A + C combinadas

**Tagline nova:** **"Você opera. Trovx executa."**
- Estrutura [humano] + [sistema]. Verbal. Posiciona humano acima da IA sem ser Luddista. 5 palavras pro café.

**Módulo principal renomeado:** **"Bridge"** (em inglês, nome próprio)
- Metáfora naval — ponte de comando. Curta, universal, premium. PT e EN. Carrega "passagem entre dois mundos".
- Linguagem consistente: "abrir a Bridge", "agentes da Bridge", "Bridge em modo noturno"

### Tradeoffs
- "Bridge" em inglês: combina com Trovx (já anglo), soa premium, evita "Ponte" telecom. Custo: pequenas fricções para público PT-BR puro.
- Tagline nova implica migrar "sob comando" para subhead/microcopy (não morrer, reposicionar)

### Reconhece que está bom
> "Tagline atual 'sob comando' tem o melhor elemento — não é 'IA te ajuda', é 'sob comando'. Diferenciado. A nova proposta preserva essa nota autoritária."

---

## Posição 3 — Diretora de Produto

### Tese
"Marca funciona bonita no showcase e fraca no mundo real. Verde definido que nunca aparece, 7 mockups internos, zero aplicações externas — exatamente onde o cliente encontra a marca pela primeira vez."

### Argumentos
- Hierarquia de cor sobrecarregada: âmbar = "executando" + "trend up" + "badge novo" + "CTA crítico". Quatro funções para uma cor. Cliente não distingue "processando" de "deu certo" sem ler texto.
- Showcase não tem uma única aplicação externa: invoice, e-mail, push, post. 90% do primeiro contato vai ser nesses canais.
- Favicon isolado falha no teste do tab bar: "x" lê como x.ai, x.com. Desaparece entre Gmail, Slack, Notion.

### Proposta concreta: Essencial Kit (antes do resto)

**Entrega 1 — Sistema semântico de cor**
- Verde `#047857` = concluído/sucesso/trend+
- Âmbar = executando/requer ação/crítico
- Aplicar em: stat trend-up (verde), status agente concluído (verde), badge "done" (verde)
- Documentar regra no `brand-guide.md`

**Entrega 2 — Três aplicações externas desenhadas antes de qualquer mockup interno novo**
- **Invoice footer** — Trovx no boleto que o cliente recebe
- **Push notification** — layout 23h47 do agente financeiro cobrando cliente
- **Email signature** — todo e-mail enviado pelos agentes

**Entrega 3 — Favicon distintivo**
- Ponto âmbar de 2px no vértice superior direito do "x"
- Lockup alternativo "símbolo dominante + wordmark menor" para thumbnails

### Tradeoffs
- Adiar novos mockups internos (hero v2, dashboard v2, command center v2)
- Mostrar aplicações externas no showcase "dilui" hero. Mitigação: seção "Como você vê a Trovx" depois do hero

### Reconhece que está bom
> "Estrutura do showcase — hero, paleta, tipografia, logo, aplicações — segue a ordem correta. Wordmark 'trov' + glifo 'x' é memorável. Preto + âmbar funciona em dark mode sem ajuste. Estamos polindo produto que tem identidade."

---

## Posição 4 — Head de Marketing de Crescimento

### Tese
"Trovx passa no teste de uma tela (showcase cheio). Não passa no teste de três: Product Hunt (thumbnail na fileira), LinkedIn (cover com 200 marcas), Twitter reply (30 marcas respondendo). Invisibilidade no ecossistema certo. E o ecossistema certo não é o Product Hunt — é a Carolina de 31 anos descobrindo por um reel de Instagram com 8 segundos."

### Argumentos
- A fileira preta é um cemitério: Linear, Vercel, Stripe, Mercury, Ramp, Replit, Cursor, Anthropic. Âmbar pontual só adiciona highlight, não identidade.
- "Trovx" não tem gancho de explicação. Cognos, Conductor, Crew, Lindy, Manus — todos têm palavra que abre conversa. Trovx só entrega "trovão + x".
- O público real (Carolina 31) não é o do PH. Está no Instagram, Google, podcast. Showcase inteiro fala pra PH viewer.

### Proposta concreta: A + B + C combinados

**Posicionamento verbal (A):** "Você opera. Trovx executa." — emparelhado, verbal, sem jargão.

**One-liner para persona real (B-versão C):** **"Sua marca, vendas e finanças em um só lugar — operado por IA."**
- Factual, sem hype, explica o que faz sem explicar como
- Diferencia de Mercury (só finanças), Ramp (só finanças), Cursor (só código)

**Validação antes de refinar (C):** Teste de 5 segundos com 3 personas reais (não fundadores de SaaS)
- Se 2/3 acertarem "sistema de agentes de IA pra rodar operação", marca está pronta
- Se não, falta posicionamento — e nenhum logo conserta isso

**Adicional:** adicionar 1 elemento visual que "pula" na fileira preta — pode ser símbolo geométrico simples que viaje bem em thumbnail 200×200.

### Tradeoffs
- Teste de 5 segundos com 3 personas custa 1 semana. Custo de descobrir em 3 meses é 10x maior.
- Símbolo arrisca "parecer marca de produtividade genérica". Aceito o risco — invisibilidade é pior que clichê bem executado.

### Reconhece que está bom
> "Paleta preto + âmbar foge do SaaS azul-roxo genérico. Vantagem competitiva real — âmbar é quente, tem energia. Não mudar a paleta. Mudar o que compete por atenção dentro dela."

---

## Pontos de convergência (4 agentes concordam)

| Ponto | Justificativa |
|---|---|
| Verde `#047857` é código morto — ativar | Diretora de Produto + Marketing |
| Aplicações externas > mockups internos | Diretora de Produto + Marketing |
| "Centro de Comando" é genérico — nome próprio do módulo | Head de Estratégia |
| Validar com usuários reais antes de iterar mais | Marketing + Produto |

## Pontos de divergência

| Tópico | Posição A | Posição B |
|---|---|---|
| Tagline | Manter "sob comando" (Diretor Tipográfico) | Trocar para "Você opera. Trovx executa." (Estratégia + Marketing) |
| Lockup/símbolo | Glifo "x" custom já é a assinatura (Diretor Tipográfico) | Falta elemento visual que pula na fileira preta (Marketing) |
| Próximo passo | Refinar mais (Diretor Tipográfico + Estratégia) | Testar com personas antes (Marketing + Produto) |

---

## Recomendação final do comitê

**Ações ordenadas por impacto, da maior pra menor:**

1. **Teste de 5 segundos com 3 personas reais** (Marketing + Produto) — antes de qualquer outra coisa. Valida se Trovx tem posicionamento defensável. 1 semana.

2. **Aplicar sistema semântico de cor** (Produto) — 30min. Resolve código morto + adiciona hierarquia funcional.

3. **Adicionar Instrument Serif Italic na login-quote** (Tipografia) — 5min. 200% mais peso na frase mais importante de venda.

4. **Desenhar 3 aplicações externas** (Produto) — invoice footer, push notification, email signature. Marca forte vive fora do produto.

5. **Decidir tagline + nome do módulo principal** (Estratégia) — "Você opera. Trovx executa." + "Bridge" como candidato. Depende do resultado do teste #1.

6. **Avaliar evolução do wordmark** (Tipografia) — peso 800 + chanfro no glifo. Só fazer se o teste #1 confirmar que vale iterar mais.

**Recomendação:** Se o teste com personas confirmar o posicionamento, aplicar #2, #3, #4 imediatamente. Adiar #5 e #6 até ver reação do público real.

---

*Comitê de marca Trovx · Ata 2026-09-10 · Próxima reunião após teste com personas*
