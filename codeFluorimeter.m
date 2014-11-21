//This software is used for data acquisition for a home made fluorimeter using a NIDAQ
//the data is then saved by the user

%DATA ACQUISITION  

exit=0
while exit == 0;
    
%SELECTION OF METHOD TO USE
disp('Sampling parameters-------------------------------------------------------')
disp(' ');
selection=input('Enter selection method, 1 for Data File, 2 for A/D converter');
   
%1. READ IN DATA FILE
    if selection == 1;
        filename=input('Input the desired filename: ', 's');

        %data=dlmread(filename);
        %data=cvsread(filename);
        data=load(filename)
        
        %Ask if want to remove mean from data 
        removeMean=input('If you want to remove the mean from each data point, enter 1, or else enter 0 ');
            
            if removeMean == 1
            data=data-mean(data); 
            end
            
        %Input time and sampling rate parameters for the simulation
        acq=input('Input the Sampling Rate in Hz used from 1000 to 2000 that was used ');
        tfinal=input('Input the total length of the acquisition time in seconds from 1 to 5 that was used ');

        t_step=1./acq; 
        t=0:t_step:tfinal;    
   
%2. DATA FROM A/D CONVERTER

    elseif selection == 2;
        %Clear workspace, close all figures and clear the command window
        clear all; close all; clc;

        %Sampling parameters-------------------------------------------------------
        disp('Sampling parameters-------------------------------------------------------')
        disp(' ');

        %Input time and sampling rate parameters for the simulation
        acq=input('Input the Sampling Rate in Hz used from 1000 to 2000 ');
        tfinal=input('Input the total length of the acquisition time in seconds from 1 to 5 ');

        t_step=1./acq; 
        t=0:t_step:tfinal;
        
        %Ask if want to remove mean from data
        removeMean=input('If you want to remove the mean from each data point, enter 1 ');
            
            if removeMean == 1
            data=data-mean(data); 
            end

        % This tells MatLab to initialize the USB device
        ai = analoginput('nidaq','Dev1');

        % Here we tell MatLab that we will be using channel 0 to acquire data
        % (channel 0 indicates that on the USB device, slot #1 denotes the ground, % and slot #2 is the positive input)
        addchannel(ai,0:1);

        % This line sets the sample rate in Hz, so 100 means 100 points per second
        set(ai, 'SampleRate', acq);

        % This tells MatLab that we want to acquire 100 points at the above
        % sample rate

        set(ai, 'SamplesPerTrigger', 300);

        % This tells MatLab to open the device, since we will be acquiring data now
        start(ai);

        % Collects the data
        data=getdata(ai)

        % Matlab puts collected values into the array called "data". Note that
        % there is no ';' at the end of the line, so Matlab will automatically
        % print out the value once it is collected. During long acquisitions the % collection routine can run in the background, allowing multiple tasks % to be performed simultaneously.
        % Notice that the data is not displayed in volts, so you need to write
        % a little routine to convert the data to the required form.
        % Now that we have the data, we no longer need the device, so we can delete it
        delete(ai);

        % We can now also clear the variable 'ai' that points to the device
        clear ai;
    

%OPTION PLOTTING OR SAVING DATA

    %Data storage--------------------------------------------------------------
        
        disp(' ');
        disp('Data storage RAW DATA--------------------------------------------------------- -----')
        disp(' ');
        
        %Store the numbers in a file.
        
            display('Do you want to store the result in a file?');
            store=input('Enter 1, if yes, otherwise enter 0 ');
            if store ==1
                    %input the filename from user
                    filename=input('Input file name: ', 's');
                    save(filename, 'data', '-ASCII');
            else
                    display ('Results will not be stored. Press Enter');
            end

        %Plotting Data----------------------------------
       
            disp(' ');
            disp('Plotting Option RAW DATA--------------------------------------------------------- -----')
            disp(' ');
            %Present Plotting option
            display('Do you want to plot the results?');
            plotSwitch=input('Enter 1, if yes, otherwise enter 0 ');
            if plotSwitch ==1
                   %Output of the plot
            subplot(5,1,4);
            plot(t,data), xlabel('time (milliseconds)'),ylabel('intensity'),title('Output of Raw data');
            refresh
            display('Paused after adding noise, view the graph, press the Enter key'); pause
            else
                    display ('Results will not be Plotted. Press Enter');
            end
            

%OPTION TO PERFORM FFT on the data

    %Fourier Analysis----------------------------------------------------------

        disp(' ');
        disp('Fourier Analysis----------------------------------------------------');
        disp(' ');

        display('Do you want to do an FFT on this data?');
        store=input('Enter 1, if yes, otherwise enter 0 ');
        
        if store ==1   

        %Generate the power spectrum by taking only the absolute values of a fast %fourier transform. The FFT amplitude is divided by the number of data points to
        %scale it in relative amplitude units.
        %To optimize the fast fourier transform, the number of points sampled
        %by the fft function should be a power of 2. As such we need the closest %power of 2 greater than or equal to your sample length. We can find this with nextpow2()
        ft1 = abs(fft(data));
        %ft1 = abs(fft(data,2^nextpow2(length(data))))/length(data);
       
        %Note that on any fast Fourier transform, the last half of the FT
        %is just a reflection of the first half, so here we display only the %first half. We can isolate the first half by limiting our frequency and %ft display vectors to the length of half of the ft1 vector minus one.
        %Calculate the frequency vector.
        f=acq*(0:(length(ft1)/2-1))/length(ft1);

    %Plot the FFT

        %Present Plotting option
        display('Do you want to plot the results of the FFT?');
        store=input('Enter 1, if yes, otherwise enter 0 ');

            if store ==1
                    %Output of the plot
                    subplot(5,1,5); plot(f,ft1(1:length(f)))
                    refresh;
                    xlabel('frequency');
                    ylabel('amplitude');
                    title(' FFT/Power Spectrum');
                    display (' End of the program. View the graph. Close the graph window.');

            else
                    display ('Results will not be Plotted. Press Enter');
            end

        else
                display ('FFT will not be calculated');
        end  
        
 exit=input('Do you want to exit the program. If yes enter 1. If you want to restart enter 0 : ');
 
    end

end    
 
