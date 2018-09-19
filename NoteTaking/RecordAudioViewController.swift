//
//  RecordViewController.swift
//  NoteTaking
//
//  Created by Siddhi Parekh on 9/16/18.
//  Copyright © 2018 Siddhi Parekh. All rights reserved.
//

//This screen will help the user to record audio and also play it

import UIKit
import AVFoundation

class RecordAudioViewController:UIViewController,AVAudioRecorderDelegate {
    
   
    
    @IBOutlet weak var playAudioButton: UIButton!
    @IBOutlet weak var exitFromEdit: UIButton!
    @IBOutlet weak var exitFromAdd: UIButton!
    @IBOutlet weak var recordAudioButton: UIButton!
    var audioURL: String!
    var note: Note?
    var audioRecorder:AVAudioRecorder!
    var audioFileName: URL!
    var audioPlayer: AVQueuePlayer? = AVQueuePlayer()
    var recordingSession:AVAudioSession!
    var fileName: String=""
    var flag: Bool = false
    var addNoteViewController = AddNoteViewController()
    var displayEditViewController = DisplayEditViewController()
    
  
   
   
    @IBAction func playAudio(_ sender: Any) {
        
        if((sender as AnyObject).titleLabel??.text=="Stop"){
            audioPlayer?.pause()
            audioPlayer = nil
            playAudioButton.setTitle("Play", for: .normal)
        }else {
            if audioFileName != nil {
            do{
           // let url = Bundle.main.url(forResource: audiofilename, withExtension: "m4a")
                playAudioButton.setTitle("Stop", for: .normal)
                if(audioPlayer==nil){
                    audioPlayer = AVQueuePlayer()
                }
                audioPlayer?.removeAllItems()
                audioPlayer?.insert(AVPlayerItem(url: audioFileName), after: nil)
                audioPlayer?.play()
            }catch {
                print("Error getting the audio file")
            }
        }else {
            createDefaultAlert(message: "There is no record to play")
        }
    }
        
    }
   
    @objc func record(){
        if audioRecorder == nil {
            createAlert()
        } else {
            finishRecording(success: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if audioFileName.absoluteString != ""{
            audioURL = audioFileName.absoluteString
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(flag){
            exitFromAdd.isEnabled=true
            exitFromEdit.isEnabled = false
            exitFromEdit.isHidden = true
            exitFromAdd.isHidden=false
        }else {
            exitFromAdd.isEnabled = false
            exitFromAdd.isHidden = true
            exitFromEdit.isEnabled = true
            exitFromEdit.isHidden = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        exitFromAdd.isEnabled = true
        exitFromAdd.isHidden = false
        exitFromEdit.isEnabled = true
        exitFromEdit.isHidden = false
    }
    
    func createAlert(){
        
        let alert = UIAlertController(title: "My Note", message: "What do you want to name the file?", preferredStyle: .alert)
        alert.addTextField (configurationHandler: {(textField : UITextField!) -> Void in
            textField.placeholder = "Enter audio filename"
            })
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            self.fileName = (alert?.textFields![0].text)! // Force unwrapping because we know it exists.
            //Print for debugging
            print("Text field: \(String(describing: self.fileName))")
            self.startRecording()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak alert] (_) in
            self.audioURL = ""
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
   //This function gets the path where the audio needs to be save
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
   
    //This function starts the recording of the audio
    func startRecording() {
        
        //Adding the file extension
        fileName = "\(fileName) \(".m4a")"
        //Print for debugging
        print("Debugging from startRecording\(fileName)")
        audioFileName = getDocumentsDirectory().appendingPathComponent(fileName)
        //Print for debugging
        print("Debugging from startRecording\(audioFileName)")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFileName, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()            
            recordAudioButton.setTitle("Stop", for: .normal)
          
        } catch {
            finishRecording(success: false)
        }
    }
    
    // This function executes when the user stops the recording
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        if success {
            recordAudioButton.setTitle("Record", for: .normal)
            createAlert2Save()
        } else {
            createDefaultAlert(message: "Something went wrong with the recording")
            recordAudioButton.setTitle("Record", for: .normal)
        }
    }
    
    func createDefaultAlert(message:String){
        let alert = UIAlertController(title: "My Note", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in   }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func createAlert2Save(){
        let alert = UIAlertController(title: "My Note", message: "Do you want to save the recording?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            self.audioURL = self.audioFileName.absoluteString
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak alert] (_) in
            self.audioURL = ""
        }))
        self.present(alert, animated: true, completion: nil)        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        audioURL=""
        recordAudioButton.addTarget(self, action: #selector(record), for: .touchUpInside)
        recordingSession = AVAudioSession.sharedInstance()
        /*self.navigationController?.navigationBar.prefersLargeTitles = false
          self.navigationController?.navigationItem.largeTitleDisplayMode = .never*/
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        
                    } else {
                      
                    }
                }
            }
        } catch {
            print(error)
        }
    }

}

extension String{
    func trim() -> String{
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
}
