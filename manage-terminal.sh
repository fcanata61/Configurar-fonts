#!/bin/bash
###############################################################################
# Script de gerenciamento de terminal X (urxvt/xterm)
# Funcionalidades:
#  - Alterna tema claro/escuro
#  - Ajusta transparência
#  - Altera tamanho da fonte
#  - Atualiza Xresources em tempo real
###############################################################################

XRESOURCES="$HOME/.Xresources"
URXVT_TRANSP=$(xrdb -query | grep URxvt.shading | awk '{print $2}')

# Função para alternar temas
toggle_theme() {
    # Detecta tema atual pela cor de background
    CURRENT_BG=$(xrdb -query | grep URxvt.background | awk '{print $2}')
    if [[ "$CURRENT_BG" == "#282828" ]]; then
        # Tema claro
        sed -i 's/URxvt.background:.*/URxvt.background: #fdf6e3/' $XRESOURCES
        sed -i 's/URxvt.foreground:.*/URxvt.foreground: #657b83/' $XRESOURCES
        sed -i 's/xterm\*background:.*/xterm*background: #fdf6e3/' $XRESOURCES
        sed -i 's/xterm\*foreground:.*/xterm*foreground: #657b83/' $XRESOURCES
        echo "Tema alterado para claro"
    else
        # Tema escuro
        sed -i 's/URxvt.background:.*/URxvt.background: #282828/' $XRESOURCES
        sed -i 's/URxvt.foreground:.*/URxvt.foreground: #ebdbb2/' $XRESOURCES
        sed -i 's/xterm\*background:.*/xterm*background: #282828/' $XRESOURCES
        sed -i 's/xterm\*foreground:.*/xterm*foreground: #ebdbb2/' $XRESOURCES
        echo "Tema alterado para escuro"
    fi
    xrdb -merge $XRESOURCES
}

# Função para ajustar transparência
adjust_transparency() {
    # Passar argumento: incremento (positivo ou negativo)
    local delta=$1
    local current=$URXVT_TRANSP
    local new=$((current + delta))
    if [ $new -lt 0 ]; then new=0; fi
    if [ $new -gt 100 ]; then new=100; fi
    xrdb -merge <<< "URxvt.shading: $new"
    echo "Transparência ajustada para $new"
}

# Função para alterar tamanho da fonte
change_font_size() {
    # Passar argumento: incremento
    local delta=$1
    # Para URxvt
    FONT_LINE=$(grep URxvt.font $XRESOURCES)
    if [[ $FONT_LINE =~ size=([0-9]+) ]]; then
        local size=${BASH_REMATCH[1]}
        local newsize=$((size + delta))
        if [ $newsize -lt 6 ]; then newsize=6; fi
        sed -i "s/size=$size/size=$newsize/" $XRESOURCES
        xrdb -merge $XRESOURCES
        echo "Tamanho da fonte ajustado para $newsize"
    fi
    # Para xterm
    XTERM_SIZE=$(grep xterm\*faceSize $XRESOURCES | awk '{print $2}')
    if [ ! -z "$XTERM_SIZE" ]; then
        local newxsize=$((XTERM_SIZE + delta))
        if [ $newxsize -lt 6 ]; then newxsize=6; fi
        sed -i "s/xterm\*faceSize:.*/xterm*faceSize: $newxsize/" $XRESOURCES
        xrdb -merge $XRESOURCES
        echo "Tamanho da fonte do xterm ajustado para $newxsize"
    fi
}

# Menu simples
echo "Selecione ação:"
echo "1) Alternar tema claro/escuro"
echo "2) Aumentar transparência (URxvt)"
echo "3) Diminuir transparência (URxvt)"
echo "4) Aumentar tamanho da fonte"
echo "5) Diminuir tamanho da fonte"
echo "0) Sair"

read -p "Escolha: " choice

case $choice in
    1) toggle_theme ;;
    2) adjust_transparency -5 ;;  # menos shading = mais transparente
    3) adjust_transparency 5 ;;   # mais shading = menos transparente
    4) change_font_size 1 ;;
    5) change_font_size -1 ;;
    0) exit 0 ;;
    *) echo "Opção inválida" ;;
esac
