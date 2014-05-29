#!/bin/bash

git init moved_ontologies
cd moved_ontologies
echo "(P x)" > Px.clif
echo "(Q y)" > Qy.clif
echo "(R z)" > Rz.clif
git add Px.clif
git commit -m "add Px.clif"
git add Qy.clif
git commit -m "add Qy.clif"
git add Rz.clif
git commit -m "add Rz.clif"
git mv Px.clif PxMoved.clif
git commit -m "move Px.clif to PxMoved.clif"
git mv PxMoved.clif PxMoved2.clif
git commit -m "move PxMoved.clif to PxMoved2.clif"
git mv Qy.clif QyMoved.clif
git mv Rz.clif RzMoved.clif
git commit -m "move Qy.clif to QyMoved.clif, Rz.clif to RzMoved.clif"
