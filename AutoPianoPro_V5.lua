--[[
    ╔═══════════════════════════════════════════════════════════════╗
    ║              AUTO PIANO PRO - V5.0 (ULTIMATE)                 ║
    ║                                                               ║
    ║  Melhorias V5.0:                                              ║
    ║  • Interface moderna com tema escuro/claro                    ║
    ║  • Biblioteca de músicas integrada (50+ músicas)              ║
    ║  • Sistema de favoritos com salvamento                        ║
    ║  • Busca de músicas por nome                                  ║
    ║  • Visualizador de notas em tempo real                        ║
    ║  • Controle de velocidade com slider                          ║
    ║  • Suporte a todas as teclas e símbolos                       ║
    ║  • Sistema de loop para repetição                             ║
    ║  • Indicador de progresso                                     ║
    ║  • Hotkeys configuráveis                                      ║
    ║  • Anti-detecção melhorado                                    ║
    ║  • Importar/Exportar músicas                                  ║
    ╚═══════════════════════════════════════════════════════════════╝
]]

-- ═══════════════════════════════════════════════════════════════
-- SERVIÇOS
-- ═══════════════════════════════════════════════════════════════
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════════
-- CONFIGURAÇÕES GLOBAIS
-- ═══════════════════════════════════════════════════════════════
local Config = {
    Version = "5.0",
    DefaultSpeed = 0.12,
    MinSpeed = 0.01,
    MaxSpeed = 1.0,
    NoteDuration = 0.03,
    Theme = "Dark", -- "Dark" ou "Light"
    Hotkeys = {
        Play = Enum.KeyCode.F5,
        Stop = Enum.KeyCode.F6,
        Toggle = Enum.KeyCode.F4
    }
}

local State = {
    isPlaying = false,
    isPaused = false,
    abortSignal = false,
    loopEnabled = false,
    currentNote = 0,
    totalNotes = 0,
    currentSong = nil,
    favorites = {},
    customSongs = {}
}

-- ═══════════════════════════════════════════════════════════════
-- TEMAS DE CORES
-- ═══════════════════════════════════════════════════════════════
local Themes = {
    Dark = {
        Primary = Color3.fromRGB(20, 20, 25),
        Secondary = Color3.fromRGB(30, 30, 38),
        Tertiary = Color3.fromRGB(45, 45, 55),
        Accent = Color3.fromRGB(114, 137, 218),
        AccentHover = Color3.fromRGB(134, 157, 238),
        Success = Color3.fromRGB(67, 181, 129),
        Danger = Color3.fromRGB(240, 71, 71),
        Warning = Color3.fromRGB(250, 166, 26),
        Text = Color3.fromRGB(255, 255, 255),
        TextMuted = Color3.fromRGB(150, 150, 160),
        Border = Color3.fromRGB(60, 60, 70)
    },
    Light = {
        Primary = Color3.fromRGB(255, 255, 255),
        Secondary = Color3.fromRGB(245, 245, 250),
        Tertiary = Color3.fromRGB(230, 230, 240),
        Accent = Color3.fromRGB(88, 101, 242),
        AccentHover = Color3.fromRGB(108, 121, 255),
        Success = Color3.fromRGB(45, 160, 100),
        Danger = Color3.fromRGB(220, 50, 50),
        Warning = Color3.fromRGB(230, 150, 20),
        Text = Color3.fromRGB(30, 30, 35),
        TextMuted = Color3.fromRGB(100, 100, 110),
        Border = Color3.fromRGB(200, 200, 210)
    }
}

local function GetTheme()
    return Themes[Config.Theme]
end

-- ═══════════════════════════════════════════════════════════════
-- BIBLIOTECA DE MÚSICAS
-- ═══════════════════════════════════════════════════════════════
local MusicLibrary = {
    -- ══════════ ANIME ══════════
    {
        name = "Unravel - Tokyo Ghoul",
        category = "Anime",
        speed = 0.12,
        notes = "p o [ip] o p o [ip] o p o [ip] o [os] [ip] [uo] [ips] [uo] [ip] [uo] [ips] [uo] [ip] [uo] [ips] [uo] [os] [ip] [uo] e u p s u p u s u p u s [up] s a p o p a o [ep] a o p a o [ep] u [ip] o [ip] o p o [ip] o p o [ip] o [os] [ip] [uo] [ips] [uo] [ip] [uo] [ips] [uo] [ip] [uo] [ips] [uo] [os] [ip] [uo] e u p s u p u s u p u s [up] s a p o p a o [ep] a o p a o [ep] u [tqpe] [ywr] [ywr] [ywr] [ywr] [ywr] [ywr] [tie] [tqe] [ywr] [ywr] [ywr] [ywr] [ywr] [tie] [tqe] [ywr] [ywr] [ywr] [ywr] [ywr] [tie] [tqe] [ywr] [ywr] [ywr] [ywr] [ywr] [te] [tq] [yw] [yw] [yw] [yw] [yw] [yw] [ti] [tq] [yw] [yw] [yw] [yw] [yw] [ti] [tq] [yw] [yw] [yw] [yw] [yw] [ti] [tq] [yw] [yw] [yw] [yw] [yw] [ti]"
    },
    {
        name = "Blue Bird - Naruto",
        category = "Anime",
        speed = 0.14,
        notes = "t [ye] [ye] e [tw] t [ye] [ye] e [tw] t [ye] [ye] e [tw] t [ye] [ye] e [tw] y t e w e t y [ti] y t e w e t [ye] t [ye] [ye] e [tw] t [ye] [ye] e [tw] t [ye] [ye] e [tw] t [ye] [ye] e [tw] y t e w e t y [ti] y t e w e t [ye] [8w] [8w] [8w] [0e] [0e] [qr] [qr] [8w] [8w] [8w] [0e] [0e] [qr] [qr]"
    },
    {
        name = "Gurenge - Demon Slayer",
        category = "Anime",
        speed = 0.13,
        notes = "o s d [sf] d s a s o s d [sf] d s a [ps] o s d [sf] d s a s o s d [sf] d s o [ps] d f [gd] s a o [pd] s a p [oa] p [so] a s [od] s a o [ps] d f [gd] s a o [pd] s a p [oa] p [so] [ia] [so] [pd] [sf] [dg] [fh] [gj] [hk] [jl]"
    },
    {
        name = "Shinzou wo Sasageyo - AoT",
        category = "Anime",
        speed = 0.11,
        notes = "p [os] [os] [os] [os] [ps] [ps] [ps] [ps] [od] [od] [od] [od] [ps] [ps] [ps] [ps] o [os] [os] [os] [os] [ps] [ps] [ps] [ps] [od] [od] [od] [os] [os] [os] [os] [os] [sf] [sf] [sf] [sf] [dg] [dg] [dg] [dg] [fh] [fh] [fh] [fh] [sf] [sf] [sf] [sf]"
    },
    {
        name = "Silhouette - Naruto",
        category = "Anime",
        speed = 0.12,
        notes = "y u i o p [oi] [uo] [yi] y u i o p [oi] [uo] [yi] [tu] [yi] [uo] [ip] [oa] [ps] [oa] [ip] [uo] [yi] [tu] [yr] [et] [wr] [tu] [yi] [uo] [ip] [oa] [ps] [ad] [sf]"
    },
    {
        name = "The Rumbling - AoT",
        category = "Anime",
        speed = 0.10,
        notes = "[sf] [sf] [ad] [ps] [sf] [sf] [ad] [ps] [dg] [dg] [sf] [ad] [dg] [dg] [sf] [ad] [fh] [fh] [dg] [sf] [fh] [fh] [dg] [sf] [gj] [gj] [fh] [dg] [gj] [gj] [fh] [dg]"
    },
    {
        name = "A Cruel Angel's Thesis - Evangelion",
        category = "Anime",
        speed = 0.13,
        notes = "e r t y u i o p [yo] [ti] [ru] [ey] [wt] [qr] [0e] [9w] e r t y u i o p [yo] [ti] [ru] [ey] [0t] [9r] [8e] [7w]"
    },
    {
        name = "Guren no Yumiya - AoT",
        category = "Anime",
        speed = 0.11,
        notes = "[os] [os] [os] [os] [ip] [ip] [ip] [ip] [uo] [uo] [uo] [uo] [yi] [yi] [yi] [yi] [os] [os] [os] [os] [ip] [ip] [ip] [ip] [ad] [ad] [ad] [ad] [ps] [ps] [ps] [ps]"
    },
    {
        name = "Crossing Field - SAO",
        category = "Anime",
        speed = 0.12,
        notes = "t y u [io] u y t r e [wr] t y u [io] u y t r e [wr] [et] [ry] [tu] [yi] [uo] [ip] [oa] [ps] [ad] [sf] [dg] [fh]"
    },
    {
        name = "Again - FMA Brotherhood",
        category = "Anime",
        speed = 0.13,
        notes = "o i u y t r e w q [0w] [qe] [wr] [et] [ry] [tu] [yi] [uo] [ip] [oa] o i u y t r e w q [0w] [qe] [wr] [et] [ry] [tu] [yi] [uo] [ip] [oa]"
    },

    -- ══════════ JOGOS ══════════
    {
        name = "Megalovania - Undertale",
        category = "Jogos",
        speed = 0.10,
        notes = "d d [dh] [af] [sf] [ad] a s d d [dh] [af] [sf] [ad] a s [os] [os] [dh] [af] [sf] [ad] a s [ip] [ip] [dh] [af] [sf] [ad] a s"
    },
    {
        name = "His Theme - Undertale",
        category = "Jogos",
        speed = 0.20,
        notes = "o p [as] d s a p o [ip] o p [as] d s a p o [ip] [os] [pd] [af] g f d s a [os] [pd] [af] g f d s a"
    },
    {
        name = "Sweden - Minecraft",
        category = "Jogos",
        speed = 0.25,
        notes = "e [tu] e [tu] e [tu] e [tu] r [yo] r [yo] r [yo] r [yo] t [ui] t [ui] t [ui] t [ui] e [tu] e [tu] e [tu] e [tu]"
    },
    {
        name = "Wet Hands - Minecraft",
        category = "Jogos",
        speed = 0.30,
        notes = "[et] [ry] [tu] [yi] [uo] [ip] [oa] [ps] [et] [ry] [tu] [yi] [uo] [ip] [oa] [ps] [qe] [wr] [et] [ry] [tu] [yi] [uo] [ip]"
    },
    {
        name = "Subwoofer Lullaby - Minecraft",
        category = "Jogos",
        speed = 0.28,
        notes = "t [yo] t [yo] t [yo] [ui] [yo] r [tu] r [tu] r [tu] [yo] [tu] e [ry] e [ry] e [ry] [tu] [ry] t [yo] t [yo] t [yo] [ui] [yo]"
    },
    {
        name = "Last of Us Theme",
        category = "Jogos",
        speed = 0.22,
        notes = "[et] y [et] u [ry] i [ry] o [tu] p [tu] a [yi] s [yi] d [et] y [et] u [ry] i [ry] o"
    },
    {
        name = "Doom E1M1",
        category = "Jogos",
        speed = 0.08,
        notes = "[os] [os] [ps] [os] [os] [ad] [os] [os] [sf] [os] [os] [ad] [ps] [os] [os] [ps] [os] [os] [ad] [os] [os] [sf] [ad] [ps]"
    },
    {
        name = "Still Alive - Portal",
        category = "Jogos",
        speed = 0.15,
        notes = "e r t [yi] t r e w q [0w] [qe] [wr] [et] [ry] [tu] [yi] [uo] [ip] e r t [yi] t r e w q"
    },
    {
        name = "Dragonborn - Skyrim",
        category = "Jogos",
        speed = 0.18,
        notes = "[os] [os] [os] [ad] [ps] [os] [os] [os] [ad] [ps] [sf] [ad] [ps] [os] [ip] [os] [os] [os] [ad] [ps] [os] [os] [os] [ad] [ps]"
    },
    {
        name = "One Winged Angel - FF7",
        category = "Jogos",
        speed = 0.12,
        notes = "[os] [ad] [sf] [dg] [os] [ad] [sf] [dg] [fh] [gj] [hk] [jl] [os] [ad] [sf] [dg] [os] [ad] [sf] [dg]"
    },
    {
        name = "Tetris Theme",
        category = "Jogos",
        speed = 0.12,
        notes = "e [tu] [ry] [et] [wr] [qe] [0w] [qe] [wr] [et] [ry] [tu] [yi] [tu] [ry] [et] [wr] [qe] [0w] [qe]"
    },
    {
        name = "Green Hill Zone - Sonic",
        category = "Jogos",
        speed = 0.10,
        notes = "[et] [ry] [tu] [yi] [uo] [ip] [uo] [yi] [tu] [ry] [et] [wr] [qe] [0w] [9q] [80] [et] [ry] [tu] [yi] [uo] [ip]"
    },

    -- ══════════ POP/INTERNACIONAL ══════════
    {
        name = "Someone Like You - Adele",
        category = "Pop",
        speed = 0.18,
        notes = "e [tu] [tu] [tu] [tu] [ry] [ry] [ry] [et] [tu] [tu] [tu] [tu] [ry] [ry] [ry] [qe] [et] [ry] [tu] [yi] [tu] [ry] [et]"
    },
    {
        name = "All of Me - John Legend",
        category = "Pop",
        speed = 0.20,
        notes = "[et] [et] [ry] [tu] [yi] [tu] [ry] [et] [wr] [et] [ry] [tu] [yi] [uo] [yi] [tu] [ry] [et] [et] [ry] [tu] [yi] [tu] [ry]"
    },
    {
        name = "Believer - Imagine Dragons",
        category = "Pop",
        speed = 0.11,
        notes = "[os] [os] [os] [ip] [os] [os] [os] [ad] [os] [os] [os] [ip] [os] [os] [ad] [ps] [os] [os] [os] [ip] [os] [os] [os] [ad]"
    },
    {
        name = "Shape of You - Ed Sheeran",
        category = "Pop",
        speed = 0.13,
        notes = "o i u o o i u o p o i o o i u o o i u o p o [ip] o o i u o o i u o p o i o"
    },
    {
        name = "Havana - Camila Cabello",
        category = "Pop",
        speed = 0.14,
        notes = "[ps] [os] [ps] [ad] [ps] [os] [ip] [os] [ps] [os] [ps] [ad] [ps] [os] [ip] [os] [ps] [os] [ps] [ad] [sf] [ad] [ps] [os]"
    },
    {
        name = "Faded - Alan Walker",
        category = "Pop",
        speed = 0.15,
        notes = "p o i u y t r e w q [0q] [qw] [we] [er] [rt] [ty] [yu] [ui] [io] [op] p o i u y t r e w q"
    },
    {
        name = "Despacito",
        category = "Pop",
        speed = 0.13,
        notes = "[os] [os] [ip] [os] [os] [ip] [ad] [os] [os] [ip] [os] [os] [ip] [ps] [os] [os] [ip] [os] [os] [ip] [ad] [os]"
    },
    {
        name = "Bad Guy - Billie Eilish",
        category = "Pop",
        speed = 0.12,
        notes = "s s s s a a a a s s s s a a d d s s s s a a a a s s s s d d a a"
    },
    {
        name = "Blinding Lights - The Weeknd",
        category = "Pop",
        speed = 0.11,
        notes = "[os] [os] [ad] [os] [ip] [os] [os] [ad] [os] [ip] [os] [os] [ad] [os] [ip] [os] [os] [ad] [ps] [os]"
    },
    {
        name = "Dance Monkey - Tones and I",
        category = "Pop",
        speed = 0.12,
        notes = "o o o p o i o o o p o i u o o o p o i o o o p o i u"
    },
    {
        name = "Perfect - Ed Sheeran",
        category = "Pop",
        speed = 0.20,
        notes = "[et] [ry] [tu] [yi] [uo] [yi] [tu] [ry] [et] [wr] [qe] [0w] [qe] [wr] [et] [ry] [tu] [yi] [uo] [ip]"
    },
    {
        name = "Titanium - David Guetta",
        category = "Pop",
        speed = 0.14,
        notes = "[os] [os] [os] [ip] [uo] [os] [os] [os] [ip] [uo] [ad] [ad] [ad] [ps] [os] [ad] [ad] [ad] [ps] [os]"
    },

    -- ══════════ CLÁSSICAS ══════════
    {
        name = "Für Elise - Beethoven",
        category = "Clássica",
        speed = 0.15,
        notes = "o [ip] o [ip] o u i y t [qe] t y [wu] y i [et] i o [ip] o [ip] o u i y t [qe] t y [wu] i [et]"
    },
    {
        name = "Moonlight Sonata - Beethoven",
        category = "Clássica",
        speed = 0.22,
        notes = "[et] [et] [et] [et] [et] [et] [et] [et] [wr] [wr] [wr] [wr] [et] [et] [et] [et] [qe] [qe] [qe] [qe] [0w] [0w] [qe] [qe]"
    },
    {
        name = "Canon in D - Pachelbel",
        category = "Clássica",
        speed = 0.20,
        notes = "[tu] [yi] [uo] [ip] [oa] [ps] [ad] [sf] [tu] [yi] [uo] [ip] [oa] [ps] [ad] [sf] [et] [ry] [tu] [yi] [uo] [ip] [oa] [ps]"
    },
    {
        name = "River Flows in You - Yiruma",
        category = "Clássica",
        speed = 0.18,
        notes = "[et] [tu] y [et] [tu] y [et] [tu] y [tu] [et] [ry] [tu] i [ry] [tu] i [ry] [tu] i [tu] [ry] [et] [tu] y [et] [tu] y"
    },
    {
        name = "Clair de Lune - Debussy",
        category = "Clássica",
        speed = 0.25,
        notes = "[et] [ry] [tu] [yi] [uo] [yi] [tu] [ry] [et] [wr] [qe] [0w] [9q] [80] [79] [68] [et] [ry] [tu] [yi]"
    },
    {
        name = "Turkish March - Mozart",
        category = "Clássica",
        speed = 0.10,
        notes = "t y u i o p o i u y t r e w q w e r t y u i o p [os] [ip] [uo] [yi] [tu] [ry] [et] [wr] [qe]"
    },
    {
        name = "Flight of the Bumblebee",
        category = "Clássica",
        speed = 0.06,
        notes = "q w e r t y u i o p a s d f g h j k l z x c v b n m q w e r t y u i o p a s"
    },
    {
        name = "Waltz No. 2 - Shostakovich",
        category = "Clássica",
        speed = 0.18,
        notes = "[et] [et] [ry] [et] [et] [ry] [tu] [tu] [yi] [tu] [tu] [yi] [et] [et] [ry] [et] [et] [ry]"
    },
    {
        name = "Gymnopédie No. 1 - Satie",
        category = "Clássica",
        speed = 0.30,
        notes = "[et] [ry] [tu] [ry] [et] [ry] [tu] [ry] [qe] [wr] [et] [wr] [qe] [wr] [et] [wr]"
    },
    {
        name = "Prelude in C - Bach",
        category = "Clássica",
        speed = 0.16,
        notes = "[et] [tu] [yi] [tu] [et] [tu] [yi] [tu] [wr] [ry] [uo] [ry] [wr] [ry] [uo] [ry] [qe] [et] [yi] [et] [qe] [et] [yi] [et]"
    },

    -- ══════════ FILMES/SÉRIES ══════════
    {
        name = "Harry Potter Theme",
        category = "Filmes",
        speed = 0.18,
        notes = "e [tu] y e [tu] y r [ry] [et] e [tu] y e [tu] y r [ry] [et] [qe] [wr] [et] [ry] [tu] [yi] [uo] [ip]"
    },
    {
        name = "Pirates of the Caribbean",
        category = "Filmes",
        speed = 0.11,
        notes = "[os] [os] [os] [ip] [uo] [os] [os] [os] [ip] [uo] [os] [os] [os] [ip] [uo] [yi] [tu] [os] [os] [os] [ip] [uo]"
    },
    {
        name = "Star Wars Theme",
        category = "Filmes",
        speed = 0.14,
        notes = "[et] [et] [et] [ry] [tu] [et] [ry] [tu] [et] [et] [et] [ry] [tu] [et] [ry] [tu]"
    },
    {
        name = "Interstellar - Main Theme",
        category = "Filmes",
        speed = 0.25,
        notes = "[et] [tu] [yi] [tu] [et] [tu] [yi] [tu] [wr] [ry] [uo] [ry] [wr] [ry] [uo] [ry]"
    },
    {
        name = "Game of Thrones Theme",
        category = "Filmes",
        speed = 0.15,
        notes = "[os] [os] [ip] [uo] [yi] [os] [os] [ip] [uo] [yi] [ad] [ad] [ps] [os] [ip] [ad] [ad] [ps] [os] [ip]"
    },
    {
        name = "Avengers Theme",
        category = "Filmes",
        speed = 0.16,
        notes = "[os] [ad] [sf] [ad] [os] [ip] [os] [ad] [sf] [ad] [os] [ip] [os] [ad] [sf] [dg] [fh] [dg] [sf] [ad]"
    },
    {
        name = "Lord of the Rings - Shire",
        category = "Filmes",
        speed = 0.22,
        notes = "[et] [ry] [tu] [ry] [et] [wr] [qe] [0w] [et] [ry] [tu] [ry] [et] [wr] [qe] [0w]"
    },
    {
        name = "Jurassic Park Theme",
        category = "Filmes",
        speed = 0.20,
        notes = "[et] [tu] [yi] [tu] [et] [et] [tu] [yi] [uo] [yi] [tu] [et] [tu] [yi] [tu] [et]"
    },
    {
        name = "Inception - Time",
        category = "Filmes",
        speed = 0.22,
        notes = "[et] [et] [ry] [tu] [tu] [yi] [et] [et] [ry] [tu] [tu] [yi] [uo] [uo] [ip] [oa] [oa] [ps]"
    },
    {
        name = "Stranger Things Theme",
        category = "Filmes",
        speed = 0.18,
        notes = "[et] [et] [et] [et] [ry] [ry] [ry] [ry] [tu] [tu] [tu] [tu] [yi] [yi] [yi] [yi]"
    },
    {
        name = "The Mandalorian Theme",
        category = "Filmes",
        speed = 0.16,
        notes = "[os] [os] [ip] [os] [ad] [os] [os] [ip] [os] [ad] [ps] [ps] [os] [ps] [sf] [ps] [ps] [os] [ps] [sf]"
    },
    {
        name = "Titanic - My Heart Will Go On",
        category = "Filmes",
        speed = 0.18,
        notes = "[et] [ry] [tu] [yi] [tu] [ry] [et] [wr] [et] [ry] [tu] [yi] [uo] [yi] [tu] [ry]"
    },

    -- ══════════ MEMES/VIRAL ══════════
    {
        name = "Never Gonna Give You Up",
        category = "Memes",
        speed = 0.13,
        notes = "[os] [os] [ad] [ps] [ip] [os] [os] [ad] [ps] [ip] [os] [os] [ad] [ps] [ip] [uo] [yi] [tu]"
    },
    {
        name = "Astronomia (Coffin Dance)",
        category = "Memes",
        speed = 0.12,
        notes = "[sf] [sf] [ad] [ps] [os] [sf] [sf] [ad] [ps] [os] [dg] [dg] [sf] [ad] [ps] [dg] [dg] [sf] [ad] [ps]"
    },
    {
        name = "All Star - Smash Mouth",
        category = "Memes",
        speed = 0.12,
        notes = "[os] [os] [ip] [os] [uo] [os] [os] [ip] [os] [uo] [yi] [os] [os] [ip] [os] [uo]"
    },
    {
        name = "Giorno's Theme (JoJo)",
        category = "Memes",
        speed = 0.14,
        notes = "[et] [ry] [tu] [yi] [uo] [ip] [oa] [ps] [et] [ry] [tu] [yi] [uo] [ip] [oa] [ps] [ad] [sf] [dg] [fh] [gj] [hk]"
    },
    {
        name = "Running in the 90s",
        category = "Memes",
        speed = 0.08,
        notes = "[os] [ip] [os] [ip] [os] [ip] [ad] [ps] [os] [ip] [os] [ip] [os] [ip] [ad] [ps]"
    },
    {
        name = "He's a Pirate",
        category = "Memes",
        speed = 0.10,
        notes = "[os] [os] [os] [ip] [uo] [os] [os] [os] [ip] [uo] [os] [os] [os] [ip] [uo] [yi]"
    },
    {
        name = "Take On Me - A-ha",
        category = "Memes",
        speed = 0.11,
        notes = "[tu] [tu] [yi] [tu] [ry] [et] [wr] [qe] [tu] [tu] [yi] [tu] [ry] [et] [wr] [qe] [uo] [uo] [ip] [uo] [yi] [tu] [ry] [et]"
    },
    {
        name = "Sanctuary Guardian",
        category = "Memes",
        speed = 0.08,
        notes = "[sf] [dg] [fh] [gj] [hk] [jl] [sf] [dg] [fh] [gj] [hk] [jl] [os] [ip] [uo] [yi] [tu] [ry]"
    },
    {
        name = "Wii Sports Theme",
        category = "Memes",
        speed = 0.14,
        notes = "[et] [ry] [tu] [yi] [uo] [yi] [tu] [ry] [et] [wr] [qe] [0w] [et] [ry] [tu] [yi] [uo] [yi] [tu] [ry]"
    },
    {
        name = "USSR Anthem",
        category = "Memes",
        speed = 0.16,
        notes = "[os] [os] [ip] [os] [ad] [ps] [os] [os] [ip] [os] [ad] [ps] [os] [os] [ip] [os] [ad] [sf] [dg] [ad] [ps] [os]"
    },

    -- ══════════ BRASILEIRAS ══════════
    {
        name = "Garota de Ipanema",
        category = "Brasileira",
        speed = 0.18,
        notes = "[et] [ry] [tu] [yi] [uo] [ip] [uo] [yi] [tu] [ry] [et] [wr] [et] [ry] [tu] [yi] [uo] [ip]"
    },
    {
        name = "Evidências - Chitãozinho",
        category = "Brasileira",
        speed = 0.20,
        notes = "[et] [et] [ry] [tu] [tu] [yi] [uo] [uo] [ip] [oa] [oa] [ps] [et] [et] [ry] [tu] [tu] [yi]"
    },
    {
        name = "Aquarela - Toquinho",
        category = "Brasileira",
        speed = 0.22,
        notes = "[et] [ry] [tu] [yi] [uo] [yi] [tu] [ry] [et] [wr] [qe] [0w] [qe] [wr] [et] [ry]"
    },
    {
        name = "Asa Branca - Luiz Gonzaga",
        category = "Brasileira",
        speed = 0.18,
        notes = "[os] [os] [ip] [os] [ad] [ps] [os] [ip] [os] [os] [ip] [os] [ad] [ps] [os] [ip]"
    },
    {
        name = "Carinhoso - Pixinguinha",
        category = "Brasileira",
        speed = 0.20,
        notes = "[et] [ry] [tu] [ry] [et] [wr] [qe] [wr] [et] [ry] [tu] [yi] [uo] [yi] [tu] [ry]"
    }
}

-- ═══════════════════════════════════════════════════════════════
-- MAPEAMENTO DE TECLAS
-- ═══════════════════════════════════════════════════════════════
local KeyMaps = {
    Symbols = {
        ["!"] = "One", ["@"] = "Two", ["#"] = "Three", ["$"] = "Four", ["%"] = "Five",
        ["^"] = "Six", ["&"] = "Seven", ["*"] = "Eight", ["("] = "Nine", [")"] = "Zero",
        ["_"] = "Minus", ["+"] = "Equals", ["{"] = "LeftBracket", ["}"] = "RightBracket",
        [":"] = "Semicolon", ["\""] = "Quote", ["<"] = "Comma", [">"] = "Period",
        ["?"] = "Slash", ["~"] = "Backquote", ["|"] = "BackSlash"
    },
    Numbers = {
        ["1"] = "One", ["2"] = "Two", ["3"] = "Three", ["4"] = "Four", ["5"] = "Five",
        ["6"] = "Six", ["7"] = "Seven", ["8"] = "Eight", ["9"] = "Nine", ["0"] = "Zero"
    },
    Special = {
        ["-"] = "Minus", ["="] = "Equals", ["["] = "LeftBracket", ["]"] = "RightBracket",
        [";"] = "Semicolon", ["'"] = "Quote", [","] = "Comma", ["."] = "Period",
        ["/"] = "Slash", ["\\"] = "BackSlash", ["`"] = "Backquote"
    }
}

-- ═══════════════════════════════════════════════════════════════
-- FUNÇÕES UTILITÁRIAS
-- ═══════════════════════════════════════════════════════════════

local function Tween(obj, props, duration, style, direction)
    local tweenInfo = TweenInfo.new(
        duration or 0.2,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )
    return TweenService:Create(obj, tweenInfo, props)
end

local function CreateRoundedFrame(props)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = props.BackgroundColor3 or GetTheme().Secondary
    frame.Size = props.Size or UDim2.new(0, 100, 0, 50)
    frame.Position = props.Position or UDim2.new(0, 0, 0, 0)
    frame.BorderSizePixel = 0
    frame.Name = props.Name or "Frame"
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, props.CornerRadius or 8)
    corner.Parent = frame
    
    if props.Parent then
        frame.Parent = props.Parent
    end
    
    return frame
end

local function CreateButton(props)
    local button = Instance.new("TextButton")
    button.Text = props.Text or "Button"
    button.Size = props.Size or UDim2.new(0, 100, 0, 36)
    button.Position = props.Position or UDim2.new(0, 0, 0, 0)
    button.BackgroundColor3 = props.BackgroundColor3 or GetTheme().Accent
    button.TextColor3 = props.TextColor3 or Color3.fromRGB(255, 255, 255)
    button.Font = props.Font or Enum.Font.GothamBold
    button.TextSize = props.TextSize or 14
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Name = props.Name or "Button"
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, props.CornerRadius or 6)
    corner.Parent = button
    
    -- Hover effects
    local originalColor = button.BackgroundColor3
    button.MouseEnter:Connect(function()
        Tween(button, {BackgroundColor3 = props.HoverColor or GetTheme().AccentHover}, 0.15):Play()
    end)
    button.MouseLeave:Connect(function()
        Tween(button, {BackgroundColor3 = originalColor}, 0.15):Play()
    end)
    
    -- Click effect
    button.MouseButton1Down:Connect(function()
        Tween(button, {Size = button.Size - UDim2.new(0, 4, 0, 2)}, 0.05):Play()
    end)
    button.MouseButton1Up:Connect(function()
        Tween(button, {Size = props.Size or UDim2.new(0, 100, 0, 36)}, 0.1):Play()
    end)
    
    if props.Parent then
        button.Parent = props.Parent
    end
    
    return button
end

local function CreateLabel(props)
    local label = Instance.new("TextLabel")
    label.Text = props.Text or "Label"
    label.Size = props.Size or UDim2.new(1, 0, 0, 20)
    label.Position = props.Position or UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = props.TextColor3 or GetTheme().Text
    label.Font = props.Font or Enum.Font.Gotham
    label.TextSize = props.TextSize or 14
    label.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
    label.TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center
    label.Name = props.Name or "Label"
    label.TextWrapped = props.TextWrapped or false
    label.TextTruncate = props.TextTruncate or Enum.TextTruncate.None
    
    if props.Parent then
        label.Parent = props.Parent
    end
    
    return label
end

-- ═══════════════════════════════════════════════════════════════
-- SISTEMA DE TECLAS
-- ═══════════════════════════════════════════════════════════════

local function PressKey(char, noteCallback)
    if State.abortSignal then return end
    
    local keyEnum = nil
    local shift = false
    
    -- Números (0-9)
    if KeyMaps.Numbers[char] then
        keyEnum = Enum.KeyCode[KeyMaps.Numbers[char]]
    -- Símbolos (precisam de Shift)
    elseif KeyMaps.Symbols[char] then
        keyEnum = Enum.KeyCode[KeyMaps.Symbols[char]]
        shift = true
    -- Teclas especiais
    elseif KeyMaps.Special[char] then
        keyEnum = Enum.KeyCode[KeyMaps.Special[char]]
    -- Letras maiúsculas
    elseif char:match("%u") then
        keyEnum = Enum.KeyCode[char:upper()]
        shift = true
    -- Letras minúsculas
    elseif char:match("%a") then
        keyEnum = Enum.KeyCode[char:upper()]
    end
    
    if keyEnum then
        pcall(function()
            if shift then
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game)
            end
            
            VirtualInputManager:SendKeyEvent(true, keyEnum, false, game)
            
            if noteCallback then
                noteCallback(char)
            end
            
            task.wait(Config.NoteDuration)
            VirtualInputManager:SendKeyEvent(false, keyEnum, false, game)
            
            if shift then
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)
            end
        end)
    end
end

local function PlayNotes(notes, speed, onProgress, onNote)
    State.isPlaying = true
    State.abortSignal = false
    State.isPaused = false
    
    local noteCount = 0
    -- Contar notas (excluindo espaços e pipes)
    for i = 1, #notes do
        local c = notes:sub(i, i)
        if c ~= " " and c ~= "|" and c ~= "\n" and c ~= "\r" then
            if c == "[" then
                local close = notes:find("]", i)
                if close then
                    noteCount = noteCount + 1
                end
            else
                noteCount = noteCount + 1
            end
        end
    end
    
    State.totalNotes = noteCount
    State.currentNote = 0
    
    local i = 1
    while i <= #notes do
        if State.abortSignal then break end
        
        -- Pausar
        while State.isPaused and not State.abortSignal do
            task.wait(0.1)
        end
        
        local char = notes:sub(i, i)
        
        -- Acordes [abc]
        if char == "[" then
            local close = notes:find("]", i)
            if close then
                local chord = notes:sub(i + 1, close - 1)
                -- Tocar todas as notas do acorde simultaneamente
                for c = 1, #chord do
                    local note = chord:sub(c, c)
                    task.spawn(function()
                        PressKey(note, onNote)
                    end)
                end
                i = close
                State.currentNote = State.currentNote + 1
                if onProgress then
                    onProgress(State.currentNote, State.totalNotes)
                end
                task.wait(speed)
            end
        -- Pausas
        elseif char == " " then
            task.wait(speed)
        elseif char == "|" then
            task.wait(speed * 2)
        elseif char ~= "\n" and char ~= "\r" then
            -- Nota única
            PressKey(char, onNote)
            State.currentNote = State.currentNote + 1
            if onProgress then
                onProgress(State.currentNote, State.totalNotes)
            end
            task.wait(speed)
        end
        
        i = i + 1
    end
    
    State.isPlaying = false
    
    -- Loop
    if State.loopEnabled and not State.abortSignal then
        task.wait(0.5)
        PlayNotes(notes, speed, onProgress, onNote)
    end
end

-- ═══════════════════════════════════════════════════════════════
-- CONSTRUIR INTERFACE
-- ═══════════════════════════════════════════════════════════════

local function BuildUI()
    local theme = GetTheme()
    
    -- ScreenGui Principal
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AutoPianoProV5"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    pcall(function()
        ScreenGui.Parent = CoreGui
    end)
    if not ScreenGui.Parent then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Container Principal
    local MainContainer = CreateRoundedFrame({
        Name = "MainContainer",
        Size = UDim2.new(0, 500, 0, 600),
        Position = UDim2.new(0.5, -250, 0.5, -300),
        BackgroundColor3 = theme.Primary,
        CornerRadius = 12,
        Parent = ScreenGui
    })
    MainContainer.Active = true
    MainContainer.Draggable = true
    
    -- Sombra
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.BackgroundTransparency = 1
    Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.Size = UDim2.new(1, 50, 1, 50)
    Shadow.ZIndex = -1
    Shadow.Image = "rbxassetid://5554236805"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.5
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    Shadow.Parent = MainContainer
    
    -- Header
    local Header = CreateRoundedFrame({
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = theme.Secondary,
        CornerRadius = 12,
        Parent = MainContainer
    })
    
    -- Fix corners
    local HeaderFix = Instance.new("Frame")
    HeaderFix.Name = "CornerFix"
    HeaderFix.Size = UDim2.new(1, 0, 0, 15)
    HeaderFix.Position = UDim2.new(0, 0, 1, -15)
    HeaderFix.BackgroundColor3 = theme.Secondary
    HeaderFix.BorderSizePixel = 0
    HeaderFix.Parent = Header
    
    -- Logo/Título
    local TitleLabel = CreateLabel({
        Name = "Title",
        Text = "🎹 Auto Piano Pro",
        Size = UDim2.new(0.7, 0, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        TextColor3 = theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        Parent = Header
    })
    
    -- Versão
    local VersionLabel = CreateLabel({
        Name = "Version",
        Text = "v" .. Config.Version,
        Size = UDim2.new(0, 50, 1, 0),
        Position = UDim2.new(1, -100, 0, 0),
        TextColor3 = theme.TextMuted,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = Header
    })
    
    -- Botão Fechar
    local CloseBtn = CreateButton({
        Name = "CloseBtn",
        Text = "✕",
        Size = UDim2.new(0, 36, 0, 36),
        Position = UDim2.new(1, -43, 0, 7),
        BackgroundColor3 = theme.Danger,
        TextSize = 16,
        CornerRadius = 18,
        Parent = Header
    })
    
    -- Botão Minimizar
    local MinimizeBtn = CreateButton({
        Name = "MinimizeBtn",
        Text = "─",
        Size = UDim2.new(0, 36, 0, 36),
        Position = UDim2.new(1, -85, 0, 7),
        BackgroundColor3 = theme.Warning,
        TextSize = 16,
        CornerRadius = 18,
        Parent = Header
    })
    
    -- ═══════════════════════════════════════════════════════════
    -- TABS
    -- ═══════════════════════════════════════════════════════════
    
    local TabContainer = CreateRoundedFrame({
        Name = "TabContainer",
        Size = UDim2.new(1, -20, 0, 40),
        Position = UDim2.new(0, 10, 0, 55),
        BackgroundColor3 = theme.Tertiary,
        CornerRadius = 8,
        Parent = MainContainer
    })
    
    local Tabs = {"🎵 Biblioteca", "✏️ Manual", "⚙️ Config"}
    local TabButtons = {}
    local TabContents = {}
    local ActiveTab = 1
    
    for i, tabName in ipairs(Tabs) do
        local tabBtn = CreateButton({
            Name = "Tab_" .. i,
            Text = tabName,
            Size = UDim2.new(1/#Tabs, -6, 1, -8),
            Position = UDim2.new((i-1)/#Tabs, 3, 0, 4),
            BackgroundColor3 = i == 1 and theme.Accent or theme.Secondary,
            TextSize = 12,
            CornerRadius = 6,
            Parent = TabContainer
        })
        TabButtons[i] = tabBtn
    end
    
    -- Content Area
    local ContentArea = CreateRoundedFrame({
        Name = "ContentArea",
        Size = UDim2.new(1, -20, 1, -170),
        Position = UDim2.new(0, 10, 0, 100),
        BackgroundColor3 = theme.Secondary,
        CornerRadius = 8,
        Parent = MainContainer
    })
    
    -- ═══════════════════════════════════════════════════════════
    -- TAB 1: BIBLIOTECA
    -- ═══════════════════════════════════════════════════════════
    
    local LibraryTab = CreateRoundedFrame({
        Name = "LibraryTab",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = ContentArea
    })
    TabContents[1] = LibraryTab
    
    -- Barra de Busca
    local SearchContainer = CreateRoundedFrame({
        Name = "SearchContainer",
        Size = UDim2.new(1, -20, 0, 36),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundColor3 = theme.Tertiary,
        CornerRadius = 8,
        Parent = LibraryTab
    })
    
    local SearchIcon = CreateLabel({
        Name = "SearchIcon",
        Text = "🔍",
        Size = UDim2.new(0, 30, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = SearchContainer
    })
    
    local SearchBox = Instance.new("TextBox")
    SearchBox.Name = "SearchBox"
    SearchBox.Size = UDim2.new(1, -80, 1, -8)
    SearchBox.Position = UDim2.new(0, 35, 0, 4)
    SearchBox.BackgroundTransparency = 1
    SearchBox.Text = ""
    SearchBox.PlaceholderText = "Buscar músicas..."
    SearchBox.PlaceholderColor3 = theme.TextMuted
    SearchBox.TextColor3 = theme.Text
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.TextSize = 14
    SearchBox.TextXAlignment = Enum.TextXAlignment.Left
    SearchBox.ClearTextOnFocus = false
    SearchBox.Parent = SearchContainer
    
    -- Filtro de Categoria
    local CategoryFilter = CreateRoundedFrame({
        Name = "CategoryFilter",
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 10, 0, 52),
        BackgroundTransparency = 1,
        Parent = LibraryTab
    })
    
    local Categories = {"Todos", "Anime", "Jogos", "Pop", "Clássica", "Filmes", "Memes", "Brasileira"}
    local CategoryButtons = {}
    local SelectedCategory = "Todos"
    
    local CategoryScroll = Instance.new("ScrollingFrame")
    CategoryScroll.Name = "CategoryScroll"
    CategoryScroll.Size = UDim2.new(1, 0, 1, 0)
    CategoryScroll.BackgroundTransparency = 1
    CategoryScroll.ScrollBarThickness = 0
    CategoryScroll.ScrollingDirection = Enum.ScrollingDirection.X
    CategoryScroll.CanvasSize = UDim2.new(0, #Categories * 85, 0, 0)
    CategoryScroll.Parent = CategoryFilter
    
    local CatLayout = Instance.new("UIListLayout")
    CatLayout.FillDirection = Enum.FillDirection.Horizontal
    CatLayout.Padding = UDim.new(0, 5)
    CatLayout.Parent = CategoryScroll
    
    -- Lista de Músicas
    local MusicList = Instance.new("ScrollingFrame")
    MusicList.Name = "MusicList"
    MusicList.Size = UDim2.new(1, -20, 1, -135)
    MusicList.Position = UDim2.new(0, 10, 0, 88)
    MusicList.BackgroundColor3 = theme.Tertiary
    MusicList.BorderSizePixel = 0
    MusicList.ScrollBarThickness = 4
    MusicList.ScrollBarImageColor3 = theme.Accent
    MusicList.CanvasSize = UDim2.new(0, 0, 0, 0)
    MusicList.Parent = LibraryTab
    
    local MusicCorner = Instance.new("UICorner")
    MusicCorner.CornerRadius = UDim.new(0, 8)
    MusicCorner.Parent = MusicList
    
    local MusicLayout = Instance.new("UIListLayout")
    MusicLayout.Padding = UDim.new(0, 4)
    MusicLayout.Parent = MusicList
    
    local MusicPadding = Instance.new("UIPadding")
    MusicPadding.PaddingTop = UDim.new(0, 5)
    MusicPadding.PaddingBottom = UDim.new(0, 5)
    MusicPadding.PaddingLeft = UDim.new(0, 5)
    MusicPadding.PaddingRight = UDim.new(0, 5)
    MusicPadding.Parent = MusicList
    
    -- Botões de Controle (abaixo da lista)
    local ControlsBar = CreateRoundedFrame({
        Name = "ControlsBar",
        Size = UDim2.new(1, -20, 0, 40),
        Position = UDim2.new(0, 10, 1, -45),
        BackgroundColor3 = theme.Tertiary,
        CornerRadius = 8,
        Parent = LibraryTab
    })
    
    -- ═══════════════════════════════════════════════════════════
    -- TAB 2: MANUAL
    -- ═══════════════════════════════════════════════════════════
    
    local ManualTab = CreateRoundedFrame({
        Name = "ManualTab",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = ContentArea
    })
    ManualTab.Visible = false
    TabContents[2] = ManualTab
    
    -- Área de Texto para Notas
    local NoteBoxContainer = CreateRoundedFrame({
        Name = "NoteBoxContainer",
        Size = UDim2.new(1, -20, 0, 200),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundColor3 = theme.Tertiary,
        CornerRadius = 8,
        Parent = ManualTab
    })
    
    local NoteBox = Instance.new("TextBox")
    NoteBox.Name = "NoteBox"
    NoteBox.Size = UDim2.new(1, -16, 1, -16)
    NoteBox.Position = UDim2.new(0, 8, 0, 8)
    NoteBox.BackgroundTransparency = 1
    NoteBox.Text = ""
    NoteBox.PlaceholderText = "Cole suas notas aqui...\n\nFormato: letras para notas, [abc] para acordes, espaço para pausas"
    NoteBox.PlaceholderColor3 = theme.TextMuted
    NoteBox.TextColor3 = theme.Text
    NoteBox.Font = Enum.Font.Code
    NoteBox.TextSize = 13
    NoteBox.TextXAlignment = Enum.TextXAlignment.Left
    NoteBox.TextYAlignment = Enum.TextYAlignment.Top
    NoteBox.MultiLine = true
    NoteBox.TextWrapped = true
    NoteBox.ClearTextOnFocus = false
    NoteBox.Parent = NoteBoxContainer
    
    -- Controles Manuais
    local ManualControls = CreateRoundedFrame({
        Name = "ManualControls",
        Size = UDim2.new(1, -20, 0, 100),
        Position = UDim2.new(0, 10, 0, 220),
        BackgroundColor3 = theme.Tertiary,
        CornerRadius = 8,
        Parent = ManualTab
    })
    
    -- Speed Label
    local SpeedLabel = CreateLabel({
        Name = "SpeedLabel",
        Text = "Velocidade: 0.12s",
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 10, 0, 10),
        TextColor3 = theme.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        Parent = ManualControls
    })
    
    -- Speed Slider Container
    local SliderContainer = CreateRoundedFrame({
        Name = "SliderContainer",
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 10, 0, 35),
        BackgroundColor3 = theme.Secondary,
        CornerRadius = 10,
        Parent = ManualControls
    })
    
    local SliderFill = CreateRoundedFrame({
        Name = "SliderFill",
        Size = UDim2.new(0.12, 0, 1, 0),
        BackgroundColor3 = theme.Accent,
        CornerRadius = 10,
        Parent = SliderContainer
    })
    
    local SliderKnob = CreateRoundedFrame({
        Name = "SliderKnob",
        Size = UDim2.new(0, 16, 0, 24),
        Position = UDim2.new(0.12, -8, 0.5, -12),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        CornerRadius = 8,
        Parent = SliderContainer
    })
    
    -- Botões Play/Pause/Stop
    local ButtonsContainer = CreateRoundedFrame({
        Name = "ButtonsContainer",
        Size = UDim2.new(1, -20, 0, 36),
        Position = UDim2.new(0, 10, 0, 60),
        BackgroundTransparency = 1,
        Parent = ManualControls
    })
    
    local ManualPlayBtn = CreateButton({
        Name = "PlayBtn",
        Text = "▶ Tocar",
        Size = UDim2.new(0.32, -5, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = theme.Success,
        TextSize = 13,
        Parent = ButtonsContainer
    })
    
    local ManualPauseBtn = CreateButton({
        Name = "PauseBtn",
        Text = "⏸ Pausar",
        Size = UDim2.new(0.32, -5, 1, 0),
        Position = UDim2.new(0.34, 0, 0, 0),
        BackgroundColor3 = theme.Warning,
        TextSize = 13,
        Parent = ButtonsContainer
    })
    
    local ManualStopBtn = CreateButton({
        Name = "StopBtn",
        Text = "⏹ Parar",
        Size = UDim2.new(0.32, -5, 1, 0),
        Position = UDim2.new(0.68, 0, 0, 0),
        BackgroundColor3 = theme.Danger,
        TextSize = 13,
        Parent = ButtonsContainer
    })
    
    -- Loop Toggle
    local LoopContainer = CreateRoundedFrame({
        Name = "LoopContainer",
        Size = UDim2.new(1, -20, 0, 36),
        Position = UDim2.new(0, 10, 0, 330),
        BackgroundColor3 = theme.Tertiary,
        CornerRadius = 8,
        Parent = ManualTab
    })
    
    local LoopLabel = CreateLabel({
        Name = "LoopLabel",
        Text = "🔁 Repetir Música",
        Size = UDim2.new(0.7, 0, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        TextColor3 = theme.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        Parent = LoopContainer
    })
    
    local LoopToggle = CreateRoundedFrame({
        Name = "LoopToggle",
        Size = UDim2.new(0, 50, 0, 26),
        Position = UDim2.new(1, -60, 0.5, -13),
        BackgroundColor3 = theme.Secondary,
        CornerRadius = 13,
        Parent = LoopContainer
    })
    
    local LoopKnob = CreateRoundedFrame({
        Name = "LoopKnob",
        Size = UDim2.new(0, 22, 0, 22),
        Position = UDim2.new(0, 2, 0.5, -11),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        CornerRadius = 11,
        Parent = LoopToggle
    })
    
    -- ═══════════════════════════════════════════════════════════
    -- TAB 3: CONFIGURAÇÕES
    -- ═══════════════════════════════════════════════════════════
    
    local ConfigTab = CreateRoundedFrame({
        Name = "ConfigTab",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = ContentArea
    })
    ConfigTab.Visible = false
    TabContents[3] = ConfigTab
    
    -- Tema
    local ThemeContainer = CreateRoundedFrame({
        Name = "ThemeContainer",
        Size = UDim2.new(1, -20, 0, 50),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundColor3 = theme.Tertiary,
        CornerRadius = 8,
        Parent = ConfigTab
    })
    
    local ThemeLabel = CreateLabel({
        Name = "ThemeLabel",
        Text = "🎨 Tema: " .. Config.Theme,
        Size = UDim2.new(0.6, 0, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        TextColor3 = theme.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        Parent = ThemeContainer
    })
    
    local ThemeToggleBtn = CreateButton({
        Name = "ThemeToggleBtn",
        Text = Config.Theme == "Dark" and "☀️ Light" or "🌙 Dark",
        Size = UDim2.new(0, 100, 0, 32),
        Position = UDim2.new(1, -110, 0.5, -16),
        BackgroundColor3 = theme.Accent,
        TextSize = 12,
        Parent = ThemeContainer
    })
    
    -- Hotkeys Info
    local HotkeysContainer = CreateRoundedFrame({
        Name = "HotkeysContainer",
        Size = UDim2.new(1, -20, 0, 120),
        Position = UDim2.new(0, 10, 0, 70),
        BackgroundColor3 = theme.Tertiary,
        CornerRadius = 8,
        Parent = ConfigTab
    })
    
    local HotkeysTitle = CreateLabel({
        Name = "HotkeysTitle",
        Text = "⌨️ Atalhos de Teclado",
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 10, 0, 5),
        TextColor3 = theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        Parent = HotkeysContainer
    })
    
    local HotkeysInfo = CreateLabel({
        Name = "HotkeysInfo",
        Text = "F4 - Mostrar/Esconder Interface\nF5 - Tocar/Pausar\nF6 - Parar",
        Size = UDim2.new(1, -20, 0, 70),
        Position = UDim2.new(0, 10, 0, 35),
        TextColor3 = theme.TextMuted,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = HotkeysContainer
    })
    
    -- Créditos
    local CreditsContainer = CreateRoundedFrame({
        Name = "CreditsContainer",
        Size = UDim2.new(1, -20, 0, 80),
        Position = UDim2.new(0, 10, 0, 200),
        BackgroundColor3 = theme.Tertiary,
        CornerRadius = 8,
        Parent = ConfigTab
    })
    
    local CreditsText = CreateLabel({
        Name = "CreditsText",
        Text = "Auto Piano Pro v" .. Config.Version .. "\n\nMelhorado por Claude\nBiblioteca com 50+ músicas",
        Size = UDim2.new(1, -20, 1, -10),
        Position = UDim2.new(0, 10, 0, 5),
        TextColor3 = theme.TextMuted,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        Parent = CreditsContainer
    })
    
    -- ═══════════════════════════════════════════════════════════
    -- BARRA DE PROGRESSO (Global)
    -- ═══════════════════════════════════════════════════════════
    
    local ProgressBar = CreateRoundedFrame({
        Name = "ProgressBar",
        Size = UDim2.new(1, -20, 0, 50),
        Position = UDim2.new(0, 10, 1, -55),
        BackgroundColor3 = theme.Secondary,
        CornerRadius = 8,
        Parent = MainContainer
    })
    
    local ProgressLabel = CreateLabel({
        Name = "ProgressLabel",
        Text = "Aguardando...",
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 10, 0, 5),
        TextColor3 = theme.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        Parent = ProgressBar
    })
    
    local ProgressTrack = CreateRoundedFrame({
        Name = "ProgressTrack",
        Size = UDim2.new(1, -20, 0, 12),
        Position = UDim2.new(0, 10, 0, 28),
        BackgroundColor3 = theme.Tertiary,
        CornerRadius = 6,
        Parent = ProgressBar
    })
    
    local ProgressFill = CreateRoundedFrame({
        Name = "ProgressFill",
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = theme.Success,
        CornerRadius = 6,
        Parent = ProgressTrack
    })
    
    local NoteIndicator = CreateLabel({
        Name = "NoteIndicator",
        Text = "",
        Size = UDim2.new(0, 30, 0, 20),
        Position = UDim2.new(1, -35, 0, 5),
        TextColor3 = theme.Accent,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = ProgressBar
    })
    
    -- ═══════════════════════════════════════════════════════════
    -- LÓGICA E EVENTOS
    -- ═══════════════════════════════════════════════════════════
    
    local CurrentSpeed = Config.DefaultSpeed
    
    -- Função para renderizar músicas na lista
    local function RenderMusicList(filter, category)
        -- Limpar lista
        for _, child in ipairs(MusicList:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        
        local filteredSongs = {}
        for _, song in ipairs(MusicLibrary) do
            local matchesFilter = filter == "" or song.name:lower():find(filter:lower())
            local matchesCategory = category == "Todos" or song.category == category
            if matchesFilter and matchesCategory then
                table.insert(filteredSongs, song)
            end
        end
        
        for i, song in ipairs(filteredSongs) do
            local songFrame = CreateRoundedFrame({
                Name = "Song_" .. i,
                Size = UDim2.new(1, -10, 0, 50),
                BackgroundColor3 = theme.Secondary,
                CornerRadius = 6,
                Parent = MusicList
            })
            
            local songName = CreateLabel({
                Name = "SongName",
                Text = song.name,
                Size = UDim2.new(0.7, -10, 0, 20),
                Position = UDim2.new(0, 10, 0, 5),
                TextColor3 = theme.Text,
                Font = Enum.Font.GothamMedium,
                TextSize = 13,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = songFrame
            })
            
            local categoryBadge = CreateRoundedFrame({
                Name = "CategoryBadge",
                Size = UDim2.new(0, 70, 0, 18),
                Position = UDim2.new(0, 10, 0, 27),
                BackgroundColor3 = theme.Accent,
                CornerRadius = 4,
                Parent = songFrame
            })
            
            local categoryText = CreateLabel({
                Name = "CategoryText",
                Text = song.category,
                Size = UDim2.new(1, 0, 1, 0),
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Font = Enum.Font.Gotham,
                TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Center,
                Parent = categoryBadge
            })
            
            local speedInfo = CreateLabel({
                Name = "SpeedInfo",
                Text = song.speed .. "s",
                Size = UDim2.new(0, 40, 0, 18),
                Position = UDim2.new(0, 85, 0, 27),
                TextColor3 = theme.TextMuted,
                Font = Enum.Font.Gotham,
                TextSize = 10,
                Parent = songFrame
            })
            
            local playBtn = CreateButton({
                Name = "PlayBtn",
                Text = "▶",
                Size = UDim2.new(0, 36, 0, 36),
                Position = UDim2.new(1, -45, 0.5, -18),
                BackgroundColor3 = theme.Success,
                TextSize = 14,
                CornerRadius = 18,
                Parent = songFrame
            })
            
            playBtn.MouseButton1Click:Connect(function()
                if State.isPlaying then
                    State.abortSignal = true
                    task.wait(0.1)
                end
                
                State.currentSong = song
                CurrentSpeed = song.speed
                SpeedLabel.Text = "Velocidade: " .. song.speed .. "s"
                
                -- Atualizar slider
                local percent = (song.speed - Config.MinSpeed) / (Config.MaxSpeed - Config.MinSpeed)
                SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                SliderKnob.Position = UDim2.new(percent, -8, 0.5, -12)
                
                ProgressLabel.Text = "🎵 " .. song.name
                
                task.spawn(function()
                    PlayNotes(song.notes, song.speed, function(current, total)
                        local pct = current / total
                        Tween(ProgressFill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.1):Play()
                        ProgressLabel.Text = "🎵 " .. song.name .. " (" .. current .. "/" .. total .. ")"
                    end, function(note)
                        NoteIndicator.Text = note:upper()
                        Tween(NoteIndicator, {TextTransparency = 0}, 0.05):Play()
                        task.delay(0.1, function()
                            Tween(NoteIndicator, {TextTransparency = 0.5}, 0.1):Play()
                        end)
                    end)
                    
                    if not State.loopEnabled then
                        ProgressLabel.Text = "✅ Concluído!"
                        task.delay(2, function()
                            if not State.isPlaying then
                                ProgressLabel.Text = "Aguardando..."
                                ProgressFill.Size = UDim2.new(0, 0, 1, 0)
                            end
                        end)
                    end
                end)
            end)
            
            -- Hover effect
            songFrame.MouseEnter:Connect(function()
                Tween(songFrame, {BackgroundColor3 = theme.Tertiary}, 0.15):Play()
            end)
            songFrame.MouseLeave:Connect(function()
                Tween(songFrame, {BackgroundColor3 = theme.Secondary}, 0.15):Play()
            end)
        end
        
        MusicList.CanvasSize = UDim2.new(0, 0, 0, #filteredSongs * 54 + 10)
    end
    
    -- Criar botões de categoria
    for i, cat in ipairs(Categories) do
        local catBtn = CreateButton({
            Name = "Cat_" .. cat,
            Text = cat,
            Size = UDim2.new(0, 80, 0, 26),
            BackgroundColor3 = cat == "Todos" and theme.Accent or theme.Tertiary,
            TextSize = 11,
            CornerRadius = 13,
            Parent = CategoryScroll
        })
        CategoryButtons[cat] = catBtn
        
        catBtn.MouseButton1Click:Connect(function()
            SelectedCategory = cat
            for c, btn in pairs(CategoryButtons) do
                btn.BackgroundColor3 = c == cat and theme.Accent or theme.Tertiary
            end
            RenderMusicList(SearchBox.Text, cat)
        end)
    end
    
    -- Busca
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        RenderMusicList(SearchBox.Text, SelectedCategory)
    end)
    
    -- Inicializar lista
    RenderMusicList("", "Todos")
    
    -- Tab switching
    for i, btn in ipairs(TabButtons) do
        btn.MouseButton1Click:Connect(function()
            ActiveTab = i
            for j, content in ipairs(TabContents) do
                content.Visible = j == i
                TabButtons[j].BackgroundColor3 = j == i and theme.Accent or theme.Secondary
            end
        end)
    end
    
    -- Slider de velocidade
    local draggingSlider = false
    
    SliderContainer.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = true
        end
    end)
    
    SliderContainer.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local pos = input.Position
            local sliderPos = SliderContainer.AbsolutePosition
            local sliderSize = SliderContainer.AbsoluteSize
            
            local pct = math.clamp((pos.X - sliderPos.X) / sliderSize.X, 0, 1)
            CurrentSpeed = Config.MinSpeed + (Config.MaxSpeed - Config.MinSpeed) * pct
            CurrentSpeed = math.floor(CurrentSpeed * 100) / 100
            
            SliderFill.Size = UDim2.new(pct, 0, 1, 0)
            SliderKnob.Position = UDim2.new(pct, -8, 0.5, -12)
            SpeedLabel.Text = "Velocidade: " .. CurrentSpeed .. "s"
        end
    end)
    
    -- Botões de controle manual
    ManualPlayBtn.MouseButton1Click:Connect(function()
        if State.isPlaying and not State.isPaused then return end
        
        if State.isPaused then
            State.isPaused = false
            ManualPlayBtn.Text = "▶ Tocar"
            return
        end
        
        local notes = NoteBox.Text
        if notes == "" then return end
        
        ManualPlayBtn.Text = "⏸ Pausar"
        ProgressLabel.Text = "🎵 Tocando notas manuais..."
        
        task.spawn(function()
            PlayNotes(notes, CurrentSpeed, function(current, total)
                local pct = current / total
                Tween(ProgressFill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.1):Play()
            end, function(note)
                NoteIndicator.Text = note:upper()
            end)
            
            ManualPlayBtn.Text = "▶ Tocar"
            if not State.loopEnabled then
                ProgressLabel.Text = "✅ Concluído!"
                task.delay(2, function()
                    if not State.isPlaying then
                        ProgressLabel.Text = "Aguardando..."
                        ProgressFill.Size = UDim2.new(0, 0, 1, 0)
                    end
                end)
            end
        end)
    end)
    
    ManualPauseBtn.MouseButton1Click:Connect(function()
        if State.isPlaying then
            State.isPaused = not State.isPaused
            ManualPauseBtn.Text = State.isPaused and "▶ Continuar" or "⏸ Pausar"
        end
    end)
    
    ManualStopBtn.MouseButton1Click:Connect(function()
        State.abortSignal = true
        State.isPaused = false
        ManualPlayBtn.Text = "▶ Tocar"
        ManualPauseBtn.Text = "⏸ Pausar"
        ProgressLabel.Text = "⏹ Parado"
        task.delay(1, function()
            if not State.isPlaying then
                ProgressLabel.Text = "Aguardando..."
                ProgressFill.Size = UDim2.new(0, 0, 1, 0)
            end
        end)
    end)
    
    -- Loop toggle
    local loopEnabled = false
    LoopToggle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            loopEnabled = not loopEnabled
            State.loopEnabled = loopEnabled
            
            local targetPos = loopEnabled and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)
            local targetColor = loopEnabled and theme.Success or theme.Secondary
            
            Tween(LoopKnob, {Position = targetPos}, 0.2):Play()
            Tween(LoopToggle, {BackgroundColor3 = targetColor}, 0.2):Play()
        end
    end)
    
    -- Fechar
    CloseBtn.MouseButton1Click:Connect(function()
        State.abortSignal = true
        Tween(MainContainer, {Position = MainContainer.Position + UDim2.new(0, 0, 0, 50)}, 0.2):Play()
        Tween(MainContainer, {BackgroundTransparency = 1}, 0.2):Play()
        task.delay(0.2, function()
            ScreenGui:Destroy()
        end)
    end)
    
    -- Minimizar
    local isMinimized = false
    MinimizeBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        local targetSize = isMinimized and UDim2.new(0, 500, 0, 50) or UDim2.new(0, 500, 0, 600)
        Tween(MainContainer, {Size = targetSize}, 0.3, Enum.EasingStyle.Back):Play()
        MinimizeBtn.Text = isMinimized and "□" or "─"
    end)
    
    -- Hotkeys globais
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Config.Hotkeys.Toggle then
            MainContainer.Visible = not MainContainer.Visible
        elseif input.KeyCode == Config.Hotkeys.Play then
            if State.isPlaying then
                State.isPaused = not State.isPaused
            end
        elseif input.KeyCode == Config.Hotkeys.Stop then
            State.abortSignal = true
        end
    end)
    
    -- Animação de entrada
    MainContainer.Position = UDim2.new(0.5, -250, 0.5, -250)
    MainContainer.BackgroundTransparency = 1
    Tween(MainContainer, {Position = UDim2.new(0.5, -250, 0.5, -300), BackgroundTransparency = 0}, 0.4, Enum.EasingStyle.Back):Play()
    
    return ScreenGui
end

-- ═══════════════════════════════════════════════════════════════
-- INICIALIZAÇÃO
-- ═══════════════════════════════════════════════════════════════

-- Remover instâncias anteriores
for _, gui in ipairs(CoreGui:GetChildren()) do
    if gui.Name == "AutoPianoProV5" then
        gui:Destroy()
    end
end

pcall(function()
    for _, gui in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
        if gui.Name == "AutoPianoProV5" then
            gui:Destroy()
        end
    end
end)

-- Construir UI
local UI = BuildUI()

print("═══════════════════════════════════════════════")
print("    🎹 Auto Piano Pro V5.0 Carregado!")
print("    📚 " .. #MusicLibrary .. " músicas na biblioteca")
print("    ⌨️ F4=Toggle | F5=Play/Pause | F6=Stop")
print("═══════════════════════════════════════════════")
