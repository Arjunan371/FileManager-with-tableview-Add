//
//  ViewController.swift
//  FileManager with tableview Add
//
//  Created by Mohammed Abdullah on 17/07/23.
//

import UIKit
import QuickLook
class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    var array:[URL] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        table.reloadData()
        // Do any additional setup after loading the view.
    }
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer){

        let vc = UIImagePickerController()
        vc.delegate = self
        present(vc, animated: true)

    }

    @IBAction func addImage(_ sender: UIButton) {
        let vc = UIImagePickerController()
        vc.delegate = self
        present(vc, animated: true)
       
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
       if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
           saveImageToDocumentsDirectory(image)
           imageView.image = image
        }
        dismiss(animated: true)
    }
    
    func createCustomDirectory() -> URL? {
        let fileManager = FileManager.default
        
        do {
            let documentsDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            print(documentsDirectory)
            let customDirectoryURL = documentsDirectory.appendingPathComponent("CustomDirectory")
            print(customDirectoryURL)
            try fileManager.createDirectory(at: customDirectoryURL, withIntermediateDirectories: true, attributes: nil)
            
            return customDirectoryURL
        } catch {
            print("Error creating custom directory: \(error)")
            return nil
        }
    }
    func saveImageToDocumentsDirectory(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            return
        }
       // let customDirectory = "CustomFolder"
        let fileManager = FileManager.default
        guard let customDirectory = createCustomDirectory() else {
            return
        }
        

        let fileName = UUID().uuidString + ".jpg"
        let fileURL = customDirectory.appendingPathComponent(fileName)

        do {
            try imageData.write(to: fileURL)
            print("Image saved to file manager successfully. File URL: \(fileURL)")
            
            array.append(fileURL)
            self.table.reloadData()// Append the file URL to the array
        } catch {
            print("Error saving image to file manager: \(error)")
        }

    }
        
        }
extension ViewController: QLPreviewControllerDelegate,QLPreviewControllerDataSource{
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return array.count
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return array[index] as QLPreviewItem
    }
}


extension ViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "one", for: indexPath) as! firstTableViewCell
        
        let imageFileURL = array[indexPath.row]
        if let imageData = try? Data(contentsOf: imageFileURL),
           let image = UIImage(data: imageData) {
            cell.imaeView.image = image
            cell.label1.text = imageFileURL.lastPathComponent
            cell.label2.text = imageFileURL.pathExtension
//            cell.delete.tag = indexPath.row
            cell.delete.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
            cell.btn.addTarget(self, action: #selector(buttons), for: .touchUpInside)
        }
        print("----good")
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    @objc func buttons(sender: UIButton) {
        if array.isEmpty {
            print("No files to preview.")
            return
        }
        let btnPos = sender.convert(CGPoint.zero, to: table)
            guard let indexPath = table.indexPathForRow(at: btnPos) else {
              return
            }
        
        let previewController = QLPreviewController()
        previewController.dataSource = self
        previewController.currentPreviewItemIndex = indexPath.row
        present(previewController, animated: true, completion: nil)
        
    }
    @objc func buttonAction(sender: UIButton) {
       print("Button tapped")
//        let row = sender.tag
        let btnPos = sender.convert(CGPoint.zero, to: table)
            guard let indexPath = table.indexPathForRow(at: btnPos) else {
              return
            }
        let fileURL = array[indexPath.row]
                do {
                    try FileManager.default.removeItem(at: fileURL)
                    array.remove(at: indexPath.row)
                    
                    table.deleteRows(at:[IndexPath(row:indexPath.row,section:0)],with:.none)
                } catch {
                    print("Error deleting file: \(error)")
                }
        if indexPath.row == 0{
            imageView.image = nil
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                let fileURL = array[indexPath.row]
                
                do {
                    try FileManager.default.removeItem(at: fileURL)
                    array.remove(at: indexPath.row)
                    table.deleteRows(at: [indexPath], with: .fade)
                    print("File deleted successfully")
                } catch {
                    print("Error deleting file: \(error)")
                }
                if indexPath.row == 0{
                    imageView.image = nil
                }
            }
        }
    }
    

    


