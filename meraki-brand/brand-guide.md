# Meraki — Sistema de Gerenciamento

> Documento de marca v1.0 · Setembro 2026

---

## 1. Conceito da Marca

### Nome: **Meraki**

Palavra grega (μεράκι) usada para descrever fazer algo com alma, criatividade e amor — colocar algo de si no que se faz.

**Por que esse nome:** Captura o espírito de quem toca um negócio próprio. Soa curto, internacional e com personalidade. Transforma "gestão" em algo com significado, não só burocracia. Tem profundidade etimológica sem ser hermético — qualquer pessoa sente o que a palavra carrega, mesmo sem conhecê-la.

**Domínio sugerido:** `meraki.app` ou `usemeraki.com` — `meraki.com` é marca registrada (Cisco Meraki).

### Propósito

Ajudar profissionais autônomos e pequenos empreendedores a transformar a complexidade do dia a dia em clareza — reunindo tarefas, clientes, projetos e finanças em um único lugar que pensa com o usuário, não apenas para ele. A marca existe para devolver tempo, foco e controle a quem escolheu construir algo próprio.

### Promessa Central

**"Tudo o que você toca no seu negócio, em um só ritmo."**

Alternativas:
- "Onde o seu negócio encontra ritmo."
- "Menos ruído. Mais progresso."

### Pilares de Marca

1. **Clareza acima de tudo** — Cada recurso responde à pergunta: "o que eu faço agora?"
2. **Humanidade em primeiro lugar** — A marca fala como gente, não como software corporativo.
3. **Movimento contínuo** — Não é sobre perfeição, é sobre ritmo. Cada pequeno avanço importa.
4. **Confiança silenciosa** — Segurança e estabilidade aparecem sem alarde — só se sente que está tudo sob controle.

### Personalidade

Calma, mas com propósito. Curiosa de verdade. Direta sem ser fria. Esteticamente cuidadosa.

### Público-Alvo (Persona)

**Carolina, 31 anos.** Designer freelancer e dona de um pequeno estúdio de branding com mais 2 pessoas. Atende de 8 a 15 clientes simultâneos. Alterna entre reuniões, execução criativa, cobrança e prestação de contas. Usa pelo menos 4 ferramentas diferentes para isso. Quer substituir o caos das planilhas e do WhatsApp sem uma semana de onboarding. Trabalha 70% no notebook, 30% no celular.

### Tom de Voz

Um colega de trabalho que é bom no que faz e respeita o seu tempo. Frases curtas, voz ativa, zero jargão. Calor humano com limites — humor leve permitido, mas sem empurração nem emojis forçados. Confiança por subtração: o cuidado com cada palavra é o que constrói credibilidade, não a quantidade de promessas.

---

## 2. Identidade Visual

### Paleta de Cores

| Função | Nome | HEX | Uso |
|---|---|---|---|
| Primária | Indigo Profundo | `#5B5BD6` | Botões primários, links, ícones de marca |
| Secundária | Ardósia Noturna | `#0C0E14` | Modo escuro, logo, textos de alto contraste |
| Secundária | Ciano Sereno | `#0F9E8F` | Status "em andamento", destaques informativos |
| Acento (CTA) | Coral Caloroso | `#FF7A45` | CTAs críticos, badges de novidades, notificações |
| Superfície | Surface Light | `#F7F8FA` | Cards, painéis elevados no modo claro |
| Texto principal | Text Primary | `#262C38` | Texto corpo no modo claro |
| Sucesso | Esmeralda | `#10B981` | Confirmações, "Concluído" |
| Erro | Vermelho | `#DC2626` | Validação, erros |
| Alerta | Âmbar | `#D97706` | Avisos, ações reversíveis |

**Ramp completa do Indigo** (de 50 a 950):
`#F2F2FE` · `#E6E6FD` · `#CBCBFA` · `#ABA9F5` · `#8683EE` · **`#5B5BD6`** · `#4747B8` · `#38389A` · `#2A2A78` · `#1C1C52` · `#0F0F2C`

**Adaptação para Dark Mode:**
- Background: `#0C0E14`
- Surface elevada: `#151922`
- Surface elevada+: `#1F2430`
- Texto primário: `#E2E5EB`
- Primary (botões): `#8683EE` (Indigo elevado para compensar fundo escuro)
- Accent CTA: `#FF8A65`

**Regra 80/15/5:** 80% neutros, 15% primary, 5% accent.

### Tipografia

| Função | Fonte | Pesos |
|---|---|---|
| Display / Títulos | **Manrope** | 500, 600, 700, 800 |
| Corpo de texto | **Inter** | 400, 500, 600, 700 |
| Interface (UI) | **Inter** | mesma do corpo |
| Mono (códigos, IDs) | **JetBrains Mono** | 400, 500 |

Links: [Manrope](https://fonts.google.com/specimen/Manrope) · [Inter](https://fonts.google.com/specimen/Inter) · [JetBrains Mono](https://fonts.google.com/specimen/JetBrains+Mono)

**Hierarquia tipográfica (base 16px, ratio 1.250):**

| Nível | Tamanho | Peso | Uso |
|---|---|---|---|
| Display | 56px | Manrope 700 | Hero landing |
| H1 | 40px | Manrope 700 | Título de página |
| H2 | 32px | Manrope 600 | Seções |
| H3 | 24px | Manrope 600 | Subseções |
| Body Large | 18px | Inter 400 | Texto de destaque |
| Body | 16px | Inter 400 | Corpo padrão |
| Body Small | 14px | Inter 400 | UI secundária |
| Caption | 12px | Inter 500 | Labels |

**Regras:** Manrope apenas em títulos (peso mínimo 500). Tabular figures ativado em colunas numéricas. Line-length ideal: 60-75 caracteres.

### Variações da Logo

- **Fundo claro:** símbolo + wordmark em `#0C0E14`, destaque em `#5B5BD6`, acento opcional em `#FF7A45` no símbolo
- **Fundo escuro:** símbolo + wordmark em `#FFFFFF`, destaque em `#8683EE`, acento em `#FF8A65`
- **Monocromática:** tudo em `#0C0E14` (claro) ou `#FFFFFF` (escuro), sem destaques
- **Favicon:** símbolo isolado em fundo gradiente `#4747B8` → `#5B5BD6`, foreground branco

### Contraste (WCAG)

- Primary sobre branco: **4.61:1** (AA passa)
- Texto principal sobre branco: **14.00:1** (AAA)
- Accent coral sobre branco: **2.59:1** — usar apenas para UI/CTA, nunca para texto corpo

---

## 3. Aplicações da Marca

Os arquivos nesta pasta mostram a marca em uso real:

- **`logo.svg`** — Logo principal (símbolo + wordmark) sobre fundo claro
- **`logo-dark.svg`** — Logo principal sobre fundo escuro
- **`logo-mark.svg`** — Apenas o símbolo (uso isolado, favicon)
- **`favicon.svg`** — Ícone simplificado para favicon (16x16, 32x32)
- **`brand-guide.html`** — Guia visual completo em HTML (cores, tipografia, aplicações)

---

## 4. Princípios Orientadores

1. **Sofisticação técnica, não decoração** — cada elemento precisa ter uma função
2. **Hierarquia clara** — seguir a regra 80/15/5
3. **Consistência de temperatura** — todos os tons (exceto accent) vivem no espectro frio
4. **Conforto visual** — neutros levemente cool-tinted harmonizam com a primary
5. **Confiança silenciosa** — não prometer demais, apenas cumprir com excelência

---

*Meraki — Sistema de Gerenciamento · Brand Guidelines v1.0*
