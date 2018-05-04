/*
  ==============================================================================

    This file was auto-generated!

    It contains the basic framework code for a JUCE plugin processor.

  ==============================================================================
*/

#include "PluginProcessor.h"
#include "PluginEditor.h"


//==============================================================================
NewProject420AudioProcessor::NewProject420AudioProcessor()
{
}

NewProject420AudioProcessor::~NewProject420AudioProcessor()
{
}

//==============================================================================
const String NewProject420AudioProcessor::getName() const
{
    return JucePlugin_Name;
}

bool NewProject420AudioProcessor::acceptsMidi() const
{
   #if JucePlugin_WantsMidiInput
    return true;
   #else
    return false;
   #endif
}

bool NewProject420AudioProcessor::producesMidi() const
{
   #if JucePlugin_ProducesMidiOutput
    return true;
   #else
    return false;
   #endif
}

double NewProject420AudioProcessor::getTailLengthSeconds() const
{
    return 0.0;
}

int NewProject420AudioProcessor::getNumPrograms()
{
    return 1;   // NB: some hosts don't cope very well if you tell them there are 0 programs,
                // so this should be at least 1, even if you're not really implementing programs.
}

int NewProject420AudioProcessor::getCurrentProgram()
{
    return 0;
}

void NewProject420AudioProcessor::setCurrentProgram (int index)
{
}

const String NewProject420AudioProcessor::getProgramName (int index)
{
    return String();
}

void NewProject420AudioProcessor::changeProgramName (int index, const String& newName)
{
}

//==============================================================================
void NewProject420AudioProcessor::prepareToPlay (double sampleRate, int samplesPerBlock)
{
    // Use this method as the place to do any pre-playback
    // initialisation that you need..
}

void NewProject420AudioProcessor::releaseResources()
{
    // When playback stops, you can use this as an opportunity to free up any
    // spare memory, etc.
}

void NewProject420AudioProcessor::processBlock (AudioSampleBuffer& buffer, MidiBuffer& midiMessages)
{
    const int totalNumInputChannels  = getTotalNumInputChannels();
    const int totalNumOutputChannels = getTotalNumOutputChannels();

    // In case we have more outputs than inputs, this code clears any output
    // channels that didn't contain input data, (because these aren't
    // guaranteed to be empty - they may contain garbage).
    // This is here to avoid people getting screaming feedback
    // when they first compile a plugin, but obviously you don't need to keep
    // this code if your algorithm always overwrites all the output channels.
    for (int i = totalNumInputChannels; i < totalNumOutputChannels; ++i)
        buffer.clear (i, 0, buffer.getNumSamples());

    // This is the place where you'd normally do the guts of your plugin's
    // audio processing...
    for (int channel = 0; channel < totalNumInputChannels; ++channel)
    {
        float* channelData = buffer.getWritePointer (channel);

        // ..do something to the data...
    }
}

//==============================================================================
bool NewProject420AudioProcessor::hasEditor() const
{
    return true; // (change this to false if you choose to not supply an editor)
}

AudioProcessorEditor* NewProject420AudioProcessor::createEditor()
{
    return new NewProject420AudioProcessorEditor (*this);
}

//==============================================================================
void NewProject420AudioProcessor::getStateInformation (MemoryBlock& destData)
{
    // You should use this method to store your parameters in the memory block.
    // You could do that either as raw data, or use the XML or ValueTree classes
    // as intermediaries to make it easy to save and load complex data.
}

void NewProject420AudioProcessor::setStateInformation (const void* data, int sizeInBytes)
{
    // You should use this method to restore your parameters from this memory block,
    // whose contents will have been created by the getStateInformation() call.
}

//==============================================================================
// This creates new instances of the plugin..
AudioProcessor* JUCE_CALLTYPE createPluginFilter()
{
    return new NewProject420AudioProcessor();
}
