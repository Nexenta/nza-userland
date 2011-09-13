#!/bin/sh
# adjust this as needed
TEXMFLOCAL=/usr/local/share/texmf


# texmf tree where lmodern fonts are installed
TEXMF=/usr/share/texmf

fonts="lmr17 lmr5 lmr6 lmr7 lmr8 lmr9 lmri10 lmri12 lmri7 lmri8 lmri9 lmro10 lmro12 lmro8 lmro9 lmss10 lmss12 lmss17 lmss8 lmss9 lmssbo10 lmssbx10 lmssdc10 lmssdo10 lmsso10 lmsso12 lmsso17 lmsso8 lmsso9 lmssq8 lmssqbo8 lmssqbx8 lmssqo8 lmtcsc10 lmtt10 lmtt12 lmtt8 lmtt9 lmtti10 lmtto10 lmvtt10 lmvtto10 lmb10 lmbo10 lmbx10 lmbx12 lmbx5 lmbx6 lmbx7 lmbx8 lmbx9 lmbxi10 lmbxo10 lmcsc10 lmcsco10 lmr10 lmr12"

mkdir -p $TEXMFLOCAL/fonts/enc/dvips/lm
ln -s      $TEXMF/fonts/enc/dvips/lm/lm-ec.enc \
      $TEXMFLOCAL/fonts/enc/dvips/lm/cork-lm.enc

mkdir -p $TEXMFLOCAL/fonts/tfm/public/lm
for font in $fonts; do
    ln -s      $TEXMF/fonts/tfm/public/lm/ec-$font.tfm \
          $TEXMFLOCAL/fonts/tfm/public/lm/cork-$font.tfm
done
mktexlsr $TEXMFLOCAL


