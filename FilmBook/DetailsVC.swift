//
//  DetailsVC.swift
//  FilmBook
//
//  Created by Bora Özel on 31/12/24.
//

import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var directorText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var chosenFilm = ""
    var chosenFilmId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenFilm != "" {
            
            saveButton.isHidden = true
            nameText.isEnabled = false
            directorText.isEnabled = false
            yearText.isEnabled = false
            
            //Core Data
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Films")
            let idString = chosenFilmId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchRequest)
                
                if results.count > 0 {
                
                    for result in results as! [NSManagedObject]{
                        if let name = result.value(forKey: "name") as? String {
                            nameText.text = name
                        }
                        
                        if let director = result.value(forKey: "director") as? String {
                            directorText.text = director
                        }
                        
                        if let year = result.value(forKey: "year") as? Int {
                            yearText.text = String(year)
                        }
                        
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                        
                    }
                    
                }
                
            }
            catch{
                print("error")
            }
            
        }
        else{
            saveButton.isEnabled = false
            saveButton.isHidden = false
        }
        
        

        //Recognizers
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
    }
    
    @objc func selectImage(){
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true)
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newFilm = NSEntityDescription.insertNewObject(forEntityName: "Films", into: context)
        
        //Attributes
        
        newFilm.setValue(nameText.text, forKey: "name")
        newFilm.setValue(directorText.text, forKey: "director")
        
        if let year = Int(yearText.text!){
            newFilm.setValue(year, forKey: "year")
        }
        
        newFilm.setValue(UUID(), forKey: "id")
        
        let data = imageView.image?.jpegData(compressionQuality: 0.5)
        newFilm.setValue(data, forKey: "image")
        
        do{
            try context.save()
            print("succesfully saved")
        }
        catch{
            print("error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
    

}
