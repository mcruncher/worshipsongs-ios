
git clone https://github.com/crunchersaspire/worshipsongs-db-dev.git bundle-db
echo "Coping latest database ..."
rm -rf worshipsongs/songs.sqlite
cp -rf bundle-db/songs.sqlite worshipsongs
rm -rf bundle-db
echo "Removed bundle-db directory"
