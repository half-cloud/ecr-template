aftman install

rm -rf Packages/
rm -rf ServerPackages/

wally install
rojo sourcemap -o sourcemap.json sourcemap.project.json

wally-package-types -s sourcemap.json Packages/
wally-package-types -s sourcemap.json ServerPackages/

touch Packages/_Index/osyrisrblx_t@3.1.1/t/.luaurc
echo "{
    \"languageMode\": \"nocheck\"
}" > Packages/_Index/osyrisrblx_t@3.1.1/t/.luaurc