# Move folder and access it
mv $HOME/KONG/konglabs/kong-ingress-controller/ $HOME/ 
cp $HOME/kong-ingress-controller/profile/dev.bashrc $HOME/ 
cd $HOME/kong-ingress-controller
rm -R $HOME/KONG/
rm -R $HOME/kong-ingress-controller/profile
rm $HOME/dev.bashrc
