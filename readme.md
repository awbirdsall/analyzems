---
title: Cheat sheet for mass spec data workup
author: Adam Birdsall
date: June 3, 2015
---

# Installation
- install matlab, including 'Bioinformatics Toolbox'
- install ProteoWizard, which includes `msconvert` utility for conversion of
mass spec files into the mzML or mzXML standard.
(http://proteowizard.sourceforge.net/user_installation.shtml)
- for command line use of `msconvert`, be sure to add the full path to the
ProteoWizard program directory (e.g., `C:\Program Files\ProteoWizard\ProteoWizard 3.07506` on my Windows machine) to the computer's PATH (e.g., Control Panel $\rightarrow$ System $\rightarrow$ Advanced System Settings $\rightarrow$ Environment Variables, then edit 'PATH' and append the ProteoWizard path to the end of the list, separated by a semicolon)

# Convert .RAW to .mzXML with msconvert

## Graphical User Interface (GUI) option
- run msconvert in GUI mode by searching `msconvert` in Start menu
- browse for .RAW file
- 'Add' each .RAW file to list
- choose output directory (or use default: same directory as .RAW file)
- output format: mzXML
- Uncheck 'Use zlib compression' (otherwise Matlab cannot read resulting file)
- 'Start'
- 'Conversion Progress' screen will inform when conversion is finished

## Command Line option
- make sure ProteoWizard directory has been added to the computer's path (see above) -- to check, see if the command `msconvert --help` causes help instructions to be printed to the screen
- use `chdir` command to change to directory containing .RAW files
- `msconvert *.RAW --mzXML` will make mzXML files from all .RAW files within the folder
- more options: `msconvert --help` or http://proteowizard.sourceforge.net/tools.shtml

# Create average spectrum in Matlab for plotting or saving to .CSV

## For a single file, using `mzxmlavg`
- Open matlab
- Make sure `mzxmlavg.m` script is in folder in the Matlab path (can add folders to path from 'Home' $\rightarrow$ 'Set path')
- Change 'current folder' to folder containing mzXML file
- Command Window: `avgspec = mzxmlavg('filename.mzXML')` substituting `filename.mzXML` as appropriate. The variable `avgspec` is now the array containing an average spectrum.

### Display or print spectrum at same time (optional)
- add additional arguments to `mzxmlavg`
- to display plot: `mzxmlavg('file.mzXML','disp');`
- to save plot to `fig.png`: `mzxmlavg('file.mzXML','save','fig.png')`

### Save spectrum to CSV
- `csvwrite('output.csv',avgspec)`, naming `output.csv` as appropriate

## For a series of files, using `mzxmlavg_batch`
- Reads mzxml files and calculates average mass spectrum for each one using `mzxmlavg`, and furthermore uses `msresample` to make sure all the mass spectra have the same series of m/z values (8500 points from 50 to 600 m/z).
- Used in `plotionsfromfile` or can be used as first step before `monitorions` (see below)
- Input: `mzxmlavg_batch(files)` where `files` is cell array of file names, e.g., `{'file_0.mzXML','file_10.mzXML','file_20.mzXML','file_30.mzXML'}`.
- Output is of form `[mz, intensities]` where `mz` is vector of shared m/z values common to each spectrum, and `intensities` is array of the intensities for each spectrum, stored in `intensities(1,:)`, `intensities(2,:)`, ...
- Sample usage:

~~~
>> fns = {'file1.mzXML','file2.mzXML'};
>> [mz,intensities] = mzxmlavg_batch(fns);
~~~

### Save each spectrum from batch to CSV

~~~
>> [mz,intensities] = mzxmlavg_batch(fns);
>> for i = 1:length(fns)
>>     csvwrite([fns{i},'.csv'],[mz,intensities(i,:)'])
>> end
~~~

# Creating a mass spectrum plot in Matlab

## Immediately after importing mzXML
- use `mzxmlavg`, see above
- calls `plotms` with `title = 'filename.mzXML'`

## Using `plotms`
- `plotms(mz,int,title)` where `title` is optional string
- makes stem plot with x and y labels of 'm/z' and 'intensity'. If `title` is included, plot is given title, 'average spectrum of '+`title`
- sample usage:

~~~
>>avgspec = mzxmlavg('file.mzXML')
>>figure
>>plotms(avgspec(:,1),avgspec(:,2),'file.mzXML data')
~~~

## Manually

~~~
>>figure
>>stem(avgspec(:,1),avgspec(:,2),'marker','none')
~~~

- see Matlab documentation for descriptions of additional commands to further customize the plot (e.g., `xlabel`, `ylabel`, `title`)
- can then save this figure externally to matlab as, e.g., .png

# Plotting selected ion intensities as function of time

## Starting from series of mzXML files
- use `plotionsfromfiles` function
- Sample usage:

~~~
>> fns = {'file_0.mzXML','file_10.mzXML','file_20.mzXML','file_30.mzXML'};
>> rxntimes = [0,10,20,30];
>> ions = [77, 119, 343];
>> plotionsfromfiles(fns,rxntimes,ions);
~~~

- list of file names needs to be surrounded by curly braces for stupid reasons. Other two arguments are in square brackets.
- order of file name list needs to correspond to the order of the reaction time list -- the script doesn't know anything based on the content of the file names
- ions are found assuming there's only one peak within +/- 0.5 m/z of each ion value input. Warning message displayed in Command Window if more than one peak found, and then it just chooses the first one.
- in addition to making the plots, `plotionsfromfiles` also returns the cell array used to make all the plots. Can hang on to that output by storing it to a variable, like `ioncts = plotionsfromfiles(fns,rxntimes,ions)`.

## Using Matlab arrays of averaged spectra

- Use `monitorions` function, results in same output (makes plots and returns `ioncts` cell array) as `plotionsfromfiles`
- Usage: `monitorions(mz,ints,times,ions,peak_tol)`
    - `mz`: single vector of m/z values describing *all* spectra
    - `ints`: array containing intensities of spectra in `ints(1,:)`, `ints(2,:)`, ...
    - `times`: reaction times of spectra, as in `plotionsfromfiles`
    - `ions`: selected ions of interest, as in `plotionsfromfiles`
    - `peak_tol`: tolerance of finding a peak within each spectra close to each m/z value listed in `ions`. If more than one peak is within the tolerance, then the first peaked is arbitrarily selected and a warning is displayed.
- `mz` and `ints` can be generated using `mzxmlavg_batch` (this is exactly what `plotionsfromfiles` does), e.g.,

~~~
>> [mz,ints] = mzxmlavg_batch(files);
>> ioncts = monitorions(mz,ints,times,ions,0.5);
~~~
