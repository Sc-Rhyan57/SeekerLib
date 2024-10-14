local ServicoUsuario = game:GetService("UserInputService")
local ServicoTween = game:GetService("TweenService")
local ServicoExecucao = game:GetService("RunService")
local JogadorLocal = game:GetService("Players").LocalPlayer
local Mouse = JogadorLocal:GetMouse()
local HttpService = game:GetService("HttpService")

local SeekerUI = {
    Elementos = {},
    TemaObjetos = {},
    Conexoes = {},
    Flags = {},
    Temas = {
        Padrao = {
            Fundo = Color3.fromRGB(35, 35, 35),
            Primario = Color3.fromRGB(45, 45, 45),
            Acento = Color3.fromRGB(85, 85, 85),
            Texto = Color3.fromRGB(240, 240, 240),
            TextoEscuro = Color3.fromRGB(150, 150, 150)
        }
    },
    TemaSelecionado = "Padrao",
    Pasta = nil,
    SalvarConfig = false
}

-- Função para detectar dispositivo móvel
local function detectarDispositivo()
    return ServicoUsuario.TouchEnabled
end

-- Função para adicionar conexões
local function adicionarConexao(Sinal, Funcao)
    local SinalConectado = Sinal:Connect(Funcao)
    table.insert(SeekerUI.Conexoes, SinalConectado)
    return SinalConectado
end

-- Função para tornar um frame arrastável
local function tornarArrastavel(PontoArraste, Janela)
    local Arrastando, EntradaArraste, PosicaoMouse, PosicaoFrame = false
    adicionarConexao(PontoArraste.InputBegan, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Arrastando = true
            PosicaoMouse = Input.Position
            PosicaoFrame = Janela.Position

            adicionarConexao(Input.Changed, function()
                if Input.UserInputState == Enum.UserInputState.End then
                    Arrastando = false
                end
            end)
        end
    end)

    adicionarConexao(PontoArraste.InputChanged, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
            EntradaArraste = Input
        end
    end)

    adicionarConexao(ServicoUsuario.InputChanged, function(Input)
        if Input == EntradaArraste and Arrastando then
            local Diferenca = Input.Position - PosicaoMouse
            Janela.Position = UDim2.new(
                PosicaoFrame.X.Scale, PosicaoFrame.X.Offset + Diferenca.X,
                PosicaoFrame.Y.Scale, PosicaoFrame.Y.Offset + Diferenca.Y
            )
        end
    end)
end

-- Função para criar elementos
local function criarElemento(Nome, Propriedades, Filhos)
    local Objeto = Instance.new(Nome)
    for i, v in pairs(Propriedades or {}) do
        Objeto[i] = v
    end
    for _, v in pairs(Filhos or {}) do
        v.Parent = Objeto
    end
    return Objeto
end

-- Função para adicionar um botão
function SeekerUI:adicionarBotao(Nome, Propriedades)
    local Botao = criarElemento("TextButton", {
        Text = Nome,
        Font = Enum.Font.GothamBold,
        TextColor3 = SeekerUI.Temas[SeekerUI.TemaSelecionado].Texto,
        BackgroundColor3 = SeekerUI.Temas[SeekerUI.TemaSelecionado].Primario,
        BorderSizePixel = 0,
        Size = Propriedades.Tamanho or UDim2.new(0, 200, 0, 50),
        Position = Propriedades.Posicao or UDim2.new(0.5, -100, 0.5, -25)
    }, {
        criarElemento("UICorner", {
            CornerRadius = UDim.new(0, 10)
        })
    })

    Botao.MouseButton1Click:Connect(function()
        Propriedades.AoClicar()
    end)

    Botao.Parent = Propriedades.Parent
    return Botao
end

-- Função para adicionar um toggle
function SeekerUI:adicionarToggle(Nome, Propriedades)
    local Toggle = criarElemento("Frame", {
        Size = Propriedades.Tamanho or UDim2.new(0, 200, 0, 50),
        BackgroundColor3 = SeekerUI.Temas[SeekerUI.TemaSelecionado].Primario
    }, {
        criarElemento("UICorner", {
            CornerRadius = UDim.new(0, 10)
        }),
        criarElemento("TextLabel", {
            Text = Nome,
            Font = Enum.Font.GothamBold,
            TextColor3 = SeekerUI.Temas[SeekerUI.TemaSelecionado].Texto,
            Size = UDim2.new(0.8, 0, 1, 0),
            BackgroundTransparency = 1
        })
    })

    local CaixaToggle = criarElemento("Frame", {
        BackgroundColor3 = Propriedades.Cor or Color3.fromRGB(0, 170, 255),
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -40, 0.5, -15)
    }, {
        criarElemento("UICorner", { CornerRadius = UDim.new(0, 6) })
    })

    CaixaToggle.Parent = Toggle

    local ativo = false
    Toggle.InputBegan:Connect(function()
        ativo = not ativo
        if ativo then
            CaixaToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        else
            CaixaToggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        end
        Propriedades.AoMudar(ativo)
    end)

    Toggle.Parent = Propriedades.Parent
    return Toggle
end

-- Função para definir tema
function SeekerUI:definirTema(Tema)
    if self.Temas[Tema] then
        self.TemaSelecionado = Tema
        for _, Objeto in pairs(self.TemaObjetos) do
            Objeto.BackgroundColor3 = self.Temas[Tema].Primario
            Objeto.TextColor3 = self.Temas[Tema].Texto
        end
    end
end

-- Função para adicionar janela
function SeekerUI:adicionarJanela(Nome, Propriedades)
    local Janela = criarElemento("Frame", {
        BackgroundColor3 = SeekerUI.Temas[SeekerUI.TemaSelecionado].Fundo,
        Size = UDim2.new(0, 400, 0, 300),
        Position = UDim2.new(0.5, -200, 0.5, -150),
        Parent = Propriedades.Parent
    })

    local TopBar = criarElemento("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = SeekerUI.Temas[SeekerUI.TemaSelecionado].Primario
    }, {
        criarElemento("TextLabel", {
            Text = Nome,
            Font = Enum.Font.GothamBold,
            TextColor3 = SeekerUI.Temas[SeekerUI.TemaSelecionado].Texto,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0)
        })
    })

    TopBar.Parent = Janela
    tornarArrastavel(TopBar, Janela)
    return Janela
end

-- Função para salvar configurações
function SeekerUI:salvarConfiguracao(NomeArquivo)
    local Dados = {}
    for Flag, Valor in pairs(SeekerUI.Flags) do
        Dados[Flag] = Valor.Valor
    end
    writefile(SeekerUI.Pasta .. "/" .. NomeArquivo .. ".json", HttpService:JSONEncode(Dados))
end

-- Função para carregar configurações
function SeekerUI:carregarConfiguracao(NomeArquivo)
    if isfile(SeekerUI.Pasta .. "/" .. NomeArquivo .. ".json") then
        local Dados = HttpService:JSONDecode(readfile(SeekerUI.Pasta .. "/" .. NomeArquivo .. ".json"))
        for Flag, Valor in pairs(Dados) do
            if SeekerUI.Flags[Flag] then
                                SeekerUI.Flags[Flag]:Setar(Valor)
            end
        end
    end
end

-- Função para criar uma notificação
function SeekerUI:adicionarNotificacao(ConfigNotificacao)
    ConfigNotificacao = ConfigNotificacao or {}
    local Notificacao = criarElemento("Frame", {
        Size = UDim2.new(0, 300, 0, 100),
        BackgroundColor3 = SeekerUI.Temas[SeekerUI.TemaSelecionado].Primario,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Parent = ConfigNotificacao.Parent
    }, {
        criarElemento("UICorner", {
            CornerRadius = UDim.new(0, 10)
        }),
        criarElemento("TextLabel", {
            Text = ConfigNotificacao.Titulo or "Notificação",
            Font = Enum.Font.GothamBold,
            TextColor3 = SeekerUI.Temas[SeekerUI.TemaSelecionado].Texto,
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundTransparency = 1
        }),
        criarElemento("TextLabel", {
            Text = ConfigNotificacao.Conteudo or "Conteúdo da notificação",
            Font = Enum.Font.GothamSemibold,
            TextColor3 = SeekerUI.Temas[SeekerUI.TemaSelecionado].TextoEscuro,
            Size = UDim2.new(1, 0, 1, -40),
            Position = UDim2.new(0, 0, 0, 40),
            BackgroundTransparency = 1,
            TextWrapped = true
        })
    })

    -- Tween de desaparecimento após tempo definido
    ServicoTween:Create(Notificacao, TweenInfo.new(0.5), {Position = UDim2.new(0.5, 0, 0.5, -150)}):Play()

    wait(ConfigNotificacao.Tempo or 5)

    ServicoTween:Create(Notificacao, TweenInfo.new(0.5), {Position = UDim2.new(0.5, 0, 0.5, 200)}):Play()
    wait(0.5)
    Notificacao:Destroy()
end

-- Função para adicionar um Slider
function SeekerUI:adicionarSlider(Nome, ConfigSlider)
    local ValorAtual = ConfigSlider.ValorInicial or ConfigSlider.Minimo or 0
    local SliderFrame = criarElemento("Frame", {
        Size = ConfigSlider.Tamanho or UDim2.new(0, 200, 0, 50),
        BackgroundColor3 = SeekerUI.Temas[SeekerUI.TemaSelecionado].Primario,
        Parent = ConfigSlider.Parent
    }, {
        criarElemento("UICorner", {
            CornerRadius = UDim.new(0, 10)
        }),
        criarElemento("TextLabel", {
            Text = Nome,
            Font = Enum.Font.GothamBold,
            TextColor3 = SeekerUI.Temas[SeekerUI.TemaSelecionado].Texto,
            Size = UDim2.new(1, 0, 0.4, 0),
            BackgroundTransparency = 1
        }),
        criarElemento("TextLabel", {
            Text = tostring(ValorAtual),
            Font = Enum.Font.GothamBold,
            TextColor3 = SeekerUI.Temas[SeekerUI.TemaSelecionado].TextoEscuro,
            Size = UDim2.new(1, 0, 0.2, 0),
            Position = UDim2.new(0, 0, 0.4, 0),
            BackgroundTransparency = 1
        })
    })

    local Bar = criarElemento("Frame", {
        BackgroundColor3 = SeekerUI.Temas[SeekerUI.TemaSelecionado].Acento,
        Size = UDim2.new(ValorAtual / ConfigSlider.Maximo, 0, 0.2, 0),
        Position = UDim2.new(0, 0, 0.8, 0)
    }, {
        criarElemento("UICorner", {
            CornerRadius = UDim.new(0, 5)
        })
    })

    Bar.Parent = SliderFrame

    -- Função para ajustar o valor do slider
    local function AjustarSlider(Posicao)
        local Proporcao = (Posicao.X - SliderFrame.AbsolutePosition.X) / SliderFrame.AbsoluteSize.X
        ValorAtual = math.clamp(math.floor(ConfigSlider.Minimo + Proporcao * (ConfigSlider.Maximo - ConfigSlider.Minimo)), ConfigSlider.Minimo, ConfigSlider.Maximo)
        SliderFrame.TextLabel.Text = tostring(ValorAtual)
        Bar.Size = UDim2.new(Proporcao, 0, 0.2, 0)
        ConfigSlider.AoMudar(ValorAtual)
    end

    SliderFrame.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            AjustarSlider(Input.Position)
        end
    end)

    SliderFrame.InputChanged:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
            AjustarSlider(Input.Position)
        end
    end)

    return SliderFrame
end

-- Função para adicionar Dropdown
function SeekerUI:adicionarDropdown(Nome, ConfigDropdown)
    local DropAberto = false
    local Dropdown = criarElemento("Frame", {
        Size = UDim2.new(0, 200, 0, 50),
        BackgroundColor3 = SeekerUI.Temas[SeekerUI.TemaSelecionado].Primario,
        Parent = ConfigDropdown.Parent
    }, {
        criarElemento("UICorner", {
            CornerRadius = UDim.new(0, 10)
        }),
        criarElemento("TextLabel", {
            Text = Nome,
            Font = Enum.Font.GothamBold,
            TextColor3 = SeekerUI.Temas[SeekerUI.TemaSelecionado].Texto,
            Size = UDim2.new(1, 0, 0.5, 0),
            BackgroundTransparency = 1
        }),
        criarElemento("TextButton", {
            Text = ConfigDropdown.Opcoes[1],
            Size = UDim2.new(1, 0, 0.5, 0),
            Position = UDim2.new(0, 0, 0.5, 0),
            BackgroundTransparency = 1
        })
    })

    local Botao = Dropdown.TextButton

    -- Função para abrir/fechar o dropdown
    Botao.MouseButton1Click:Connect(function()
        DropAberto = not DropAberto
        if DropAberto then
            for _, Opcao in pairs(ConfigDropdown.Opcoes) do
                local OpcaoBotao = criarElemento("TextButton", {
                    Text = Opcao,
                    Size = UDim2.new(1, 0, 0.2, 0),
                    BackgroundTransparency = 1,
                    Parent = Dropdown
                })
                OpcaoBotao.MouseButton1Click:Connect(function()
                    Botao.Text = Opcao
                    ConfigDropdown.AoMudar(Opcao)
                end)
            end
        else
            for _, Elemento in pairs(Dropdown:GetChildren()) do
                if Elemento:IsA("TextButton") and Elemento ~= Botao then
                    Elemento:Destroy()
                end
            end
        end
    end)

    return Dropdown
end

-- Função para adicionar Caixa de Texto
function SeekerUI:adicionarCaixaTexto(Nome, ConfigCaixaTexto)
    local CaixaTexto = criarElemento("Frame", {
        Size = UDim2.new(0, 200, 0, 50),
        BackgroundColor3 = SeekerUI.Temas[SeekerUI.TemaSelecionado].Primario,
        Parent = ConfigCaixaTexto.Parent
    }, {
        criarElemento("UICorner", {
            CornerRadius = UDim.new(0, 10)
        }),
        criarElemento("TextLabel", {
            Text = Nome,
            Font = Enum.Font.GothamBold,
            TextColor3 = SeekerUI.Temas[SeekerUI.TemaSelecionado].Texto,
            Size = UDim2.new(1, 0, 0.5, 0),
            BackgroundTransparency = 1
        }),
        criarElemento("TextBox", {
            Text = ConfigCaixaTexto.TextoPadrao or "",
            Size = UDim2.new(1, 0, 0.5, 0),
            Position = UDim2.new(0, 0, 0.5, 0),
            BackgroundTransparency = 1,
            TextColor3 = SeekerUI.Temas[SeekerUI.TemaSelecionado].Texto
        })
    })

    local Caixa = CaixaTexto.TextBox

    Caixa.FocusLost:Connect(function()
        ConfigCaixaTexto.AoPerderFoco(Caixa.Text)
    end)

    return CaixaTexto
end

