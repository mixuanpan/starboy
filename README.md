![LOGO](images/STARBOY_F2_LOGO.PNG)
## Project Overview 

Authors - Mixuan Pan, Myles Querimit, Cristian Martinez, and Safa Islam

Mentor -  Johnny Hazboun

FPGA implementation of Tetris with VGA display. Features an AI Accelerator for infernces on an model. 

## Instructions 
### Testbench with non-constant indexing 
``` bash 
# without miguel's magic 
~ece270/bin/sv2v -w [newfile.v] [oldfile.sv] # e.g. ~ece270/bin/sv2v -w tetrisFSM.v /home/shay/a/mart2667/July18/starboy-5/source/tetrisFSM.sv 

# MIGUEL'S MAGIC 
make sv2v [filname] # e.g. make sv2v_tetrisFSM
make sim_[filename]_src_converted # e.g. make sim_tetrisFSM_src_converted
```
### Git Source Control 
#### Terminal Console (preferred/sometimes VScode takes forever to sync changes) 
``` bash 
git pull 
git status # shows the modified/added/deleted files  
git add . # add all changes or add [filename] to add specific files 
git commit 
```
```v
G // go to the last line
o // make a new line 
[esc key] // escape insert mode 
// make a short commit comment
// (optional) make a blank line after and comment longer messages  
:x // execute 
```
``` bash 
git push -u origin main
``` 
#### VScode 
``` bash 
git pull 
git push
```
- go to source control and comment your commit  
- sync changes

### Testbench current CPU Performance 
``` bash 
python3 test_mmu.py --depth 4 --size 4 --iters 100000
```

## Brain rot 
i love matcha

Cristian Andres Martinez is 6'3 and buff and a feminist

## References 

Main Python/Model Repository: [GitHub](https://github.com/mylesqpurdue/starboy_ai/blob/main/README.md)

Sources: [Zotero Library](https://www.zotero.org/groups/6044707/starboy/library) 

Testing: [Documentation](https://docs.google.com/document/d/1tzC2W0r-rnmzguaRiXUXlHRb8Z0UypnSorqynxr-XQ4/edit?usp=sharing)

## Built with ❤️ at Purdue STARS 2025
