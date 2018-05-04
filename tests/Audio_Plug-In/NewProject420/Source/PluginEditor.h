/*
  ==============================================================================

    This file was auto-generated!

    It contains the basic framework code for a JUCE plugin editor.

  ==============================================================================
*/

#ifndef PLUGINEDITOR_H_INCLUDED
#define PLUGINEDITOR_H_INCLUDED

#include "../JuceLibraryCode/JuceHeader.h"
#include "PluginProcessor.h"


//==============================================================================
/**
*/
class NewProject420AudioProcessorEditor  : public AudioProcessorEditor
{
public:
    NewProject420AudioProcessorEditor (NewProject420AudioProcessor&);
    ~NewProject420AudioProcessorEditor();

    //==============================================================================
    void paint (Graphics&) override;
    void resized() override;

private:
    // This reference is provided as a quick way for your editor to
    // access the processor object that created it.
    NewProject420AudioProcessor& processor;

    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR (NewProject420AudioProcessorEditor)
};


#endif  // PLUGINEDITOR_H_INCLUDED
