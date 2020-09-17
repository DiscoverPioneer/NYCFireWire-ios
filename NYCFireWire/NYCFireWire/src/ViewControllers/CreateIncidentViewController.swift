//
//  CreateIncidentViewController.swift
//  NYCFireWire
//
//  Created by Phil Scarfi on 11/23/18.
//  Copyright © 2018 Pioneer Mobile Applications, LLC. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import RSSelectionMenu

enum PickerViewTags: Int {
    case incidentType = 0
    case boro = 1
}

class CreateIncidentViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var formView: UIView!
    @IBOutlet weak var postButton: UIButton!
    let formVC = MountainClimberController()
    var allTextFields = [String:UITextField]()
    var selectedRespondingUnits = [RespondingUnit]()
    
    @IBOutlet weak var coordinatesLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create Incident"
        setupUI()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
}

//MARK: - Helpers
extension CreateIncidentViewController {
    fileprivate func setupUI() {

        let titleTF = addTextField(name: "title", placeHolder: "Title")
        titleTF.addDoneButtonOnKeyboard()
        let incidentTypePicker = titleTF.usePickerView()
        incidentTypePicker.tag = PickerViewTags.incidentType.rawValue
        incidentTypePicker.delegate = self
        incidentTypePicker.dataSource = self
        
        let boroTF = addTextField(name: "boro", placeHolder: "Boro")
        boroTF.addDoneButtonOnKeyboard()
        let boroPicker = boroTF.usePickerView()
        boroPicker.tag = PickerViewTags.boro.rawValue
        boroPicker.delegate = self
        boroPicker.dataSource = self
        let boxNumberTF = addTextField(name: "boxNumber", placeHolder: "Box Number")
        boxNumberTF.keyboardType = .numberPad
        boxNumberTF.addDoneButtonOnKeyboard()
        let addressTF = addTextField(name: "address", placeHolder: "Address")
        let subtitleTF = addTextField(name: "subtitle", placeHolder: "Subtitle/Description")
        subtitleTF.autocapitalizationType = .sentences
        
        let respondingUnits = UIButton(frame: CGRect(x: 0, y: 0, width: 250, height: 40))
        respondingUnits.setTitle("Responding Units", for: .normal)
        respondingUnits.setTitleColor(UIColor.white, for: .normal)
        respondingUnits.addTarget(self, action: #selector(CreateIncidentViewController.showRespondingUnits), for: .touchUpInside)
        
        let postButton = UIButton(frame: CGRect(x: 0, y: 0, width: 250, height: 40))
        postButton.setTitle("Post Incident", for: .normal)
        postButton.setTitleColor(UIColor.white, for: .normal)
        postButton.addTarget(self, action: #selector(CreateIncidentViewController.postAsIncidentTapped(sender:)), for: .touchUpInside)
        formVC.allViews = [titleTF, boroTF, boxNumberTF, addressTF, subtitleTF, respondingUnits, postButton]
        addChild(page:formVC , toView: formView)
        setNavBar()
    }
    
    fileprivate func setNavBar() {
        title = "Post Incident"
        navigationController?.navigationBar.tintColor = UIColor.white
        let locationBtn = UIButton(type: .custom)
        locationBtn.frame = CGRect(x: 0.0, y: 0.0, width: 20, height: 20)
        locationBtn.setImage(UIImage(named:"LocationFinder"), for: .normal)
        locationBtn.addTarget(self, action: #selector(CreateIncidentViewController.scrollToUserLocation), for: UIControl.Event.touchUpInside)
        let locationButton = locationBtn.convertToBarButtonItem()
        let fixedSpace = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
        fixedSpace.width = 10
        let searchButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(CreateIncidentViewController.searchButtonTapped))
        navigationItem.rightBarButtonItems = [searchButton, fixedSpace, locationButton]
        
    }
    
    fileprivate func addTextField(name: String, placeHolder: String) -> UITextField {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 250, height: 40))
        textField.textAlignment = .center
        textField.textColor = UIColor.white
        textField.autocapitalizationType = .words
        textField.delegate = self
        textField.backgroundColor = UIColor.white
        textField.textColor = UIColor.fireWireGray
        textField.placeholder = placeHolder
        textField.font = UIFont(name: "TimesNewRomanPSMT", size: 17)
        textField.setPlaceHolderColor(color: UIColor.fireWireGray)
        self.allTextFields[name] = textField
        return textField
    }
    
    func searchAddress(address: String) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            if let location = placemarks?.first?.location?.coordinate {
                self.mapView.setCenterCoordinate(centerCoordinate: location, zoomLevel: 14, animated: true)
                self.allTextFields["address"]?.text = address
            }
        }
    }
    
    func clearTextFields() {
        for (key,_) in allTextFields {
           allTextFields[key] = nil
        }
        selectedRespondingUnits.removeAll()
    }
}

//MARK - MapKit Delegate
extension CreateIncidentViewController: MKMapViewDelegate {
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        setPin()
        let location = mapView.region.center
        coordinatesLabel.text = "\(location.latitude.rounded(toPlaces: 3)),\(location.longitude.rounded(toPlaces: 3))"
    }
    
    func setPin() {
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        let annotation = ImageAnnotation()
        annotation.coordinate = self.mapView.region.center
        self.mapView.addAnnotation(annotation)
    }
    
    func convertCoordinates(coordinates: CLLocationCoordinate2D, completed: @escaping () -> Void) {
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            var fullAddress = ""
            // Location name
            if let locationName = placeMark.name {
                print("1: \(locationName)")
                fullAddress = locationName
            } else {
                // Street address
                if let streetNumber = placeMark.subThoroughfare {
                    print("2a: \(streetNumber)")
                    fullAddress = "\(fullAddress) \(streetNumber)"
                }
                
                // Street address
                if let street = placeMark.thoroughfare {
                    print("2b: \(street)")
                    fullAddress = "\(fullAddress) \(street)"
                }
            }
            
            // City
            if let city = placeMark.locality {
                print("3: \(city)")
                fullAddress = "\(fullAddress), \(city)"
            }
            // Country
            if let state = placeMark.administrativeArea {
                print("5: \(state)")
                fullAddress = "\(fullAddress), \(state)"
            }
            self.allTextFields["address"]?.text = fullAddress
            completed()
        })
    }
    
    func fieldsAreValid() -> Bool {
        for (key, _) in allTextFields {
            if allTextFields[key]?.text == nil || allTextFields[key]?.text?.isEmpty == true {
                return false
            }
        }
        if selectedRespondingUnits.count == 0 {
            return false
        }
        
        return true
    }
    
    func customIncident() {
        let alert = UIAlertController(title: "Custom Incident Type", message: "Type your custom incident", preferredStyle: UIAlertController.Style.alert)
        
        alert.addTextField(configurationHandler: incidentConfigurationTextField)
        
        alert.addAction(UIAlertAction(title: "Use Incident Type", style: UIAlertAction.Style.default, handler:{ (UIAlertAction)in
            print("User click Ok button")
            if let textField = alert.textFields?.first, let name = textField.text {
                self.allTextFields["title"]?.text = name
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler:{ (UIAlertAction)in }))
        self.allTextFields["title"]?.text = nil
        self.present(alert, animated: true, completion: nil)
    }
    
    func incidentConfigurationTextField(textField: UITextField){
        textField.placeholder = "Incident Type"
        textField.keyboardType = UIKeyboardType.alphabet
        textField.textAlignment = .center
        textField.autocapitalizationType = .words
    }
}

//MARK: - Actions
extension CreateIncidentViewController {
    @IBAction func scrollToUserLocation() {
        if let location = LocationManager.shared.manager.location?.coordinate {
            let activity = view.showActivity()
            mapView.setCenterCoordinate(centerCoordinate: location, zoomLevel: 14, animated: true)
            
            convertCoordinates(coordinates: mapView.region.center) {
                activity.stopAnimating()
            }
        }
    }
    
    @IBAction func searchButtonTapped() {
        let alert = UIAlertController(title: "Search Location", message: "Enter a location to search", preferredStyle: UIAlertController.Style.alert)
        
        alert.addTextField(configurationHandler: configurationTextField)
        
        alert.addAction(UIAlertAction(title: "Search", style: UIAlertAction.Style.default, handler:{ (UIAlertAction)in
            print("User click Ok button")
            if let textField = alert.textFields?.first, let address = textField.text {
                self.searchAddress(address: address)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler:{ (UIAlertAction)in }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func configurationTextField(textField: UITextField){
        textField.placeholder = "Address, City, State"
        textField.keyboardType = UIKeyboardType.alphabet
        textField.textAlignment = .center
        textField.autocapitalizationType = .words
    }
    
    @IBAction func postAsIncidentTapped(sender: Any) {
        if !fieldsAreValid() {
            showAlert(title: "Error", message: "Make Sure that all fields are filled in and you have selected at least 1 responding unit")
            return
        }
        let confirm = UIAlertAction(title: "Confirm", style: .default) { (action) in
            print("Send Incident")
            self.sendIncident()
        }
        showAlert(title: "Incident\nPlease confirm all information", message: "Title: \(allTextFields["title"]!.text!)\nBox #: \(allTextFields["boxNumber"]!.text!)\nBoro: \(allTextFields["boro"]!.text!)\nAddress: \(allTextFields["address"]!.text!)\nResponding Units: \(selectedRespondingUnits.map{$0.name})\nCoordinates: \(coordinatesLabel.text!)\nDescription: \(allTextFields["subtitle"]!.text!)", actions: [confirm])
    }
    
    func sendIncident() {
        let params:[String:Any] = [
            "title":allTextFields["title"]!.text!,
            "box_number":allTextFields["boxNumber"]!.text!,
            "subtitle":allTextFields["subtitle"]!.text!,
            "address":allTextFields["address"]!.text!,
            "latitude":mapView.region.center.latitude,
            "longitude":mapView.region.center.longitude,
            "boro":allTextFields["boro"]!.text!,
            "responding_units_final":selectedRespondingUnits.map{$0.name}
        ]
        let activity = view.showActivity()
        APIController.defaults.createIncidentWithParams(params: params) { (success) in
            activity.stopAnimating()
            print("Created Incident:")
            if success {
                self.showBasicAlert(title: "Successfully created incident", message: "Check the incident section to stay up to date", dismissed: {
                    self.clearTextFields()
                    AppManager.shared.menu?.currentState = .menuExpanded
                    AppManager.shared.menu?.didSelectMenuOption(index: 0)
                })
            } else {
                self.showAlert(title: "Error", message: "Something went wrong. Please try again later")
            }
        }
    }
}

//MARK: - UIPickerView DataSource & Delegate
extension CreateIncidentViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == PickerViewTags.incidentType.rawValue {
            return PickerData.incidentTypes.count
        } else if pickerView.tag == PickerViewTags.boro.rawValue {
            return PickerData.boros.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == PickerViewTags.incidentType.rawValue {
            return PickerData.incidentTypes[row]
        } else if pickerView.tag == PickerViewTags.boro.rawValue {
            return PickerData.boros[row]
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == PickerViewTags.incidentType.rawValue {
            if PickerData.incidentTypes[row] == "Custom" {
             customIncident()
                return
            }
            allTextFields["title"]?.text = PickerData.incidentTypes[row]
        } else if pickerView.tag == PickerViewTags.boro.rawValue {
            allTextFields["boro"]?.text = PickerData.boros[row]
        }
    }
}

extension CreateIncidentViewController {
    @objc func showRespondingUnits() {
        let selectionMenu = RSSelectionMenu(selectionType: .Multiple, dataSource: PickerData.units.map{$0.name}, cellType: .Basic) { (cell, object, indexPath) in
            cell.textLabel?.text = object
        }
        
        selectionMenu.setSelectedItems(items: selectedRespondingUnits.map{$0.name}, maxSelected: 50) { (text, selected, selectedItems) in
        }
        
        selectionMenu.show(style: .Formsheet, from: self)

        selectionMenu.onDismiss = { selectedItems in
            self.selectedRespondingUnits = selectedItems.map{RespondingUnit(name: $0)}
        }
        
        selectionMenu.showSearchBar { (searchtext) -> ([String]) in
            return PickerData.units.filter({
                $0.name.lowercased().range(of:searchtext.lowercased()) != nil
            }).map{$0.name}
        }
    }
}

class PickerData {
    static let boros = ["Brooklyn", "Bronx", "Manhattan", "Queens", "Staten Island", "Long Island", "Outside NYC"]
    static let incidentTypes = [
        "All Hands",
        "10-75",
        "10-76",
        "10-77",
        "2nd Alarm",
        "3rd Alarm",
        "4th Alarm",
        "5th Alarm",
        "6th Alarm",
        "7th Alarm",
        "8th Alarm",
        "9th Alarm",
        "10-60/Major Emergency",
        "Tech Rescue",
        "HazMat",
        "Water Rescue",
        "Maritime Emergency",
        "MVA/Overturned",
        "MVA/Pin",
        "Serious MVA",
        "Collapse",
        "Subway Emergency",
        "Terror Alert",
        "Confined Space",
        "Unusual Incident",
        "High Angle Rescue",
        "NYPD Incident",
        "Major Incident",
        "Working Fire",
        "Custom"
    ]
    
    static let units = [
        RespondingUnit(name:"Bn-1"),
        RespondingUnit(name:"Bn-10"),
        RespondingUnit(name:"Bn-11"),
        RespondingUnit(name:"Bn-12"),
        RespondingUnit(name:"Bn-13"),
        RespondingUnit(name:"Bn-14"),
        RespondingUnit(name:"Bn-15"),
        RespondingUnit(name:"Bn-16"),
        RespondingUnit(name:"Bn-17"),
        RespondingUnit(name:"Bn-18"),
        RespondingUnit(name:"Bn-19"),
        RespondingUnit(name:"Bn-2"),
        RespondingUnit(name:"Bn-20"),
        RespondingUnit(name:"Bn-21"),
        RespondingUnit(name:"Bn-22"),
        RespondingUnit(name:"Bn-23"),
        RespondingUnit(name:"Bn-26"),
        RespondingUnit(name:"Bn-27"),
        RespondingUnit(name:"Bn-28"),
        RespondingUnit(name:"Bn-3"),
        RespondingUnit(name:"Bn-31"),
        RespondingUnit(name:"Bn-32"),
        RespondingUnit(name:"Bn-33"),
        RespondingUnit(name:"Bn-35"),
        RespondingUnit(name:"Bn-37"),
        RespondingUnit(name:"Bn-38"),
        RespondingUnit(name:"Bn-39"),
        RespondingUnit(name:"Bn-4"),
        RespondingUnit(name:"Bn-40"),
        RespondingUnit(name:"Bn-41"),
        RespondingUnit(name:"Bn-42"),
        RespondingUnit(name:"Bn-43"),
        RespondingUnit(name:"Bn-44"),
        RespondingUnit(name:"Bn-45"),
        RespondingUnit(name:"Bn-46"),
        RespondingUnit(name:"Bn-47"),
        RespondingUnit(name:"Bn-48"),
        RespondingUnit(name:"Bn-49"),
        RespondingUnit(name:"Bn-50"),
        RespondingUnit(name:"Bn-51"),
        RespondingUnit(name:"Bn-52"),
        RespondingUnit(name:"Bn-53"),
        RespondingUnit(name:"Bn-54"),
        RespondingUnit(name:"Bn-57"),
        RespondingUnit(name:"Bn-58"),
        RespondingUnit(name:"Bn-6"),
        RespondingUnit(name:"Bn-7"),
        RespondingUnit(name:"Bn-8"),
        RespondingUnit(name:"Bn-9"),
        RespondingUnit(name:"Div-1"),
        RespondingUnit(name:"Div-11"),
        RespondingUnit(name:"Div-13"),
        RespondingUnit(name:"Div-14"),
        RespondingUnit(name:"Div-15"),
        RespondingUnit(name:"Div-3"),
        RespondingUnit(name:"Div-6"),
        RespondingUnit(name:"Div-8"),
        RespondingUnit(name:"Div.7"),
        RespondingUnit(name:"E-1"),
        RespondingUnit(name:"E-10"),
        RespondingUnit(name:"E-14"),
        RespondingUnit(name:"E-15"),
        RespondingUnit(name:"E-151"),
        RespondingUnit(name:"E-152"),
        RespondingUnit(name:"E-153"),
        RespondingUnit(name:"E-155"),
        RespondingUnit(name:"E-156"),
        RespondingUnit(name:"E-157"),
        RespondingUnit(name:"E-158"),
        RespondingUnit(name:"E-159"),
        RespondingUnit(name:"E-16"),
        RespondingUnit(name:"E-160"),
        RespondingUnit(name:"E-161"),
        RespondingUnit(name:"E-162"),
        RespondingUnit(name:"E-163"),
        RespondingUnit(name:"E-164"),
        RespondingUnit(name:"E-165"),
        RespondingUnit(name:"E-166"),
        RespondingUnit(name:"E-167"),
        RespondingUnit(name:"E-168"),
        RespondingUnit(name:"E-201"),
        RespondingUnit(name:"E-202"),
        RespondingUnit(name:"E-205"),
        RespondingUnit(name:"E-206"),
        RespondingUnit(name:"E-207"),
        RespondingUnit(name:"E-21"),
        RespondingUnit(name:"E-210"),
        RespondingUnit(name:"E-211"),
        RespondingUnit(name:"E-214"),
        RespondingUnit(name:"E-216"),
        RespondingUnit(name:"E-217"),
        RespondingUnit(name:"E-218"),
        RespondingUnit(name:"E-219"),
        RespondingUnit(name:"E-22"),
        RespondingUnit(name:"E-220"),
        RespondingUnit(name:"E-221"),
        RespondingUnit(name:"E-222"),
        RespondingUnit(name:"E-224"),
        RespondingUnit(name:"E-225"),
        RespondingUnit(name:"E-226"),
        RespondingUnit(name:"E-227"),
        RespondingUnit(name:"E-228"),
        RespondingUnit(name:"E-229"),
        RespondingUnit(name:"E-23"),
        RespondingUnit(name:"E-230"),
        RespondingUnit(name:"E-231"),
        RespondingUnit(name:"E-233"),
        RespondingUnit(name:"E-234"),
        RespondingUnit(name:"E-235"),
        RespondingUnit(name:"E-236"),
        RespondingUnit(name:"E-237"),
        RespondingUnit(name:"E-238"),
        RespondingUnit(name:"E-239"),
        RespondingUnit(name:"E-24"),
        RespondingUnit(name:"E-240"),
        RespondingUnit(name:"E-241"),
        RespondingUnit(name:"E-242"),
        RespondingUnit(name:"E-243"),
        RespondingUnit(name:"E-245"),
        RespondingUnit(name:"E-246"),
        RespondingUnit(name:"E-247"),
        RespondingUnit(name:"E-248"),
        RespondingUnit(name:"E-249"),
        RespondingUnit(name:"E-250"),
        RespondingUnit(name:"E-251"),
        RespondingUnit(name:"E-253"),
        RespondingUnit(name:"E-254"),
        RespondingUnit(name:"E-255"),
        RespondingUnit(name:"E-257"),
        RespondingUnit(name:"E-258"),
        RespondingUnit(name:"E-259"),
        RespondingUnit(name:"E-26"),
        RespondingUnit(name:"E-260"),
        RespondingUnit(name:"E-262"),
        RespondingUnit(name:"E-263"),
        RespondingUnit(name:"E-264"),
        RespondingUnit(name:"E-265"),
        RespondingUnit(name:"E-266"),
        RespondingUnit(name:"E-268"),
        RespondingUnit(name:"E-271"),
        RespondingUnit(name:"E-273"),
        RespondingUnit(name:"E-274"),
        RespondingUnit(name:"E-275"),
        RespondingUnit(name:"E-276"),
        RespondingUnit(name:"E-277"),
        RespondingUnit(name:"E-279"),
        RespondingUnit(name:"E-28"),
        RespondingUnit(name:"E-280"),
        RespondingUnit(name:"E-281"),
        RespondingUnit(name:"E-282"),
        RespondingUnit(name:"E-283"),
        RespondingUnit(name:"E-284"),
        RespondingUnit(name:"E-285"),
        RespondingUnit(name:"E-286"),
        RespondingUnit(name:"E-287"),
        RespondingUnit(name:"E-289"),
        RespondingUnit(name:"E-290"),
        RespondingUnit(name:"E-291"),
        RespondingUnit(name:"E-292"),
        RespondingUnit(name:"E-293"),
        RespondingUnit(name:"E-294"),
        RespondingUnit(name:"E-295"),
        RespondingUnit(name:"E-297"),
        RespondingUnit(name:"E-298"),
        RespondingUnit(name:"E-299"),
        RespondingUnit(name:"E-3"),
        RespondingUnit(name:"E-301"),
        RespondingUnit(name:"E-302"),
        RespondingUnit(name:"E-303"),
        RespondingUnit(name:"E-304"),
        RespondingUnit(name:"E-305"),
        RespondingUnit(name:"E-306"),
        RespondingUnit(name:"E-307"),
        RespondingUnit(name:"E-308"),
        RespondingUnit(name:"E-309"),
        RespondingUnit(name:"E-310"),
        RespondingUnit(name:"E-311"),
        RespondingUnit(name:"E-312"),
        RespondingUnit(name:"E-313"),
        RespondingUnit(name:"E-314"),
        RespondingUnit(name:"E-315"),
        RespondingUnit(name:"E-316"),
        RespondingUnit(name:"E-317"),
        RespondingUnit(name:"E-318"),
        RespondingUnit(name:"E-319"),
        RespondingUnit(name:"E-320"),
        RespondingUnit(name:"E-321"),
        RespondingUnit(name:"E-323"),
        RespondingUnit(name:"E-324"),
        RespondingUnit(name:"E-325"),
        RespondingUnit(name:"E-326"),
        RespondingUnit(name:"E-328"),
        RespondingUnit(name:"E-329"),
        RespondingUnit(name:"E-33"),
        RespondingUnit(name:"E-330"),
        RespondingUnit(name:"E-331"),
        RespondingUnit(name:"E-332"),
        RespondingUnit(name:"E-34"),
        RespondingUnit(name:"E-35"),
        RespondingUnit(name:"E-37"),
        RespondingUnit(name:"E-38"),
        RespondingUnit(name:"E-39"),
        RespondingUnit(name:"E-4"),
        RespondingUnit(name:"E-40"),
        RespondingUnit(name:"E-42"),
        RespondingUnit(name:"E-43"),
        RespondingUnit(name:"E-44"),
        RespondingUnit(name:"E-45"),
        RespondingUnit(name:"E-46"),
        RespondingUnit(name:"E-47"),
        RespondingUnit(name:"E-48"),
        RespondingUnit(name:"E-5"),
        RespondingUnit(name:"E-50"),
        RespondingUnit(name:"E-52"),
        RespondingUnit(name:"E-53"),
        RespondingUnit(name:"E-54"),
        RespondingUnit(name:"E-55"),
        RespondingUnit(name:"E-58"),
        RespondingUnit(name:"E-59"),
        RespondingUnit(name:"E-6"),
        RespondingUnit(name:"E-60"),
        RespondingUnit(name:"E-62"),
        RespondingUnit(name:"E-63"),
        RespondingUnit(name:"E-64"),
        RespondingUnit(name:"E-65"),
        RespondingUnit(name:"E-66"),
        RespondingUnit(name:"E-67"),
        RespondingUnit(name:"E-68"),
        RespondingUnit(name:"E-69"),
        RespondingUnit(name:"E-7"),
        RespondingUnit(name:"E-70"),
        RespondingUnit(name:"E-71"),
        RespondingUnit(name:"E-72"),
        RespondingUnit(name:"E-73"),
        RespondingUnit(name:"E-74"),
        RespondingUnit(name:"E-75"),
        RespondingUnit(name:"E-76"),
        RespondingUnit(name:"E-79"),
        RespondingUnit(name:"E-8"),
        RespondingUnit(name:"E-80"),
        RespondingUnit(name:"E-81"),
        RespondingUnit(name:"E-82"),
        RespondingUnit(name:"E-83"),
        RespondingUnit(name:"E-84"),
        RespondingUnit(name:"E-88"),
        RespondingUnit(name:"E-89"),
        RespondingUnit(name:"E-9"),
        RespondingUnit(name:"E-90"),
        RespondingUnit(name:"E-91"),
        RespondingUnit(name:"E-92"),
        RespondingUnit(name:"E-93"),
        RespondingUnit(name:"E-94"),
        RespondingUnit(name:"E-95"),
        RespondingUnit(name:"E-96"),
        RespondingUnit(name:"E-97"),
        RespondingUnit(name:"HazMat"),
        RespondingUnit(name:"HazMat 1"),
        RespondingUnit(name:"L-10"),
        RespondingUnit(name:"L-101"),
        RespondingUnit(name:"L-102"),
        RespondingUnit(name:"L-103"),
        RespondingUnit(name:"L-104"),
        RespondingUnit(name:"L-106"),
        RespondingUnit(name:"L-108"),
        RespondingUnit(name:"L-109"),
        RespondingUnit(name:"L-11"),
        RespondingUnit(name:"L-110"),
        RespondingUnit(name:"L-112"),
        RespondingUnit(name:"L-113"),
        RespondingUnit(name:"L-116"),
        RespondingUnit(name:"L-118"),
        RespondingUnit(name:"L-122"),
        RespondingUnit(name:"L-123"),
        RespondingUnit(name:"L-125"),
        RespondingUnit(name:"L-126"),
        RespondingUnit(name:"L-128"),
        RespondingUnit(name:"L-129"),
        RespondingUnit(name:"L-130"),
        RespondingUnit(name:"L-132"),
        RespondingUnit(name:"L-133"),
        RespondingUnit(name:"L-134"),
        RespondingUnit(name:"L-136"),
        RespondingUnit(name:"L-137"),
        RespondingUnit(name:"L-140"),
        RespondingUnit(name:"L-143"),
        RespondingUnit(name:"L-147"),
        RespondingUnit(name:"L-148"),
        RespondingUnit(name:"L-149"),
        RespondingUnit(name:"L-150"),
        RespondingUnit(name:"L-151"),
        RespondingUnit(name:"L-154"),
        RespondingUnit(name:"L-156"),
        RespondingUnit(name:"L-16"),
        RespondingUnit(name:"TL-161"),
        RespondingUnit(name:"L-164"),
        RespondingUnit(name:"L-165"),
        RespondingUnit(name:"L-166"),
        RespondingUnit(name:"L-167"),
        RespondingUnit(name:"L-168"),
        RespondingUnit(name:"L-169"),
        RespondingUnit(name:"L-173"),
        RespondingUnit(name:"L-174"),
        RespondingUnit(name:"L-175"),
        RespondingUnit(name:"L-176"),
        RespondingUnit(name:"L-19"),
        RespondingUnit(name:"L-2"),
        RespondingUnit(name:"L-20"),
        RespondingUnit(name:"L-24"),
        RespondingUnit(name:"L-25"),
        RespondingUnit(name:"L-26"),
        RespondingUnit(name:"L-27"),
        RespondingUnit(name:"L-28"),
        RespondingUnit(name:"L-29"),
        RespondingUnit(name:"L-3"),
        RespondingUnit(name:"L-30"),
        RespondingUnit(name:"L-32"),
        RespondingUnit(name:"L-34"),
        RespondingUnit(name:"L-36"),
        RespondingUnit(name:"L-37"),
        RespondingUnit(name:"L-38"),
        RespondingUnit(name:"L-39"),
        RespondingUnit(name:"L-4"),
        RespondingUnit(name:"L-40"),
        RespondingUnit(name:"L-42"),
        RespondingUnit(name:"L-43"),
        RespondingUnit(name:"L-47"),
        RespondingUnit(name:"L-48"),
        RespondingUnit(name:"L-49"),
        RespondingUnit(name:"L-5"),
        RespondingUnit(name:"L-52"),
        RespondingUnit(name:"L-55"),
        RespondingUnit(name:"L-56"),
        RespondingUnit(name:"L-59"),
        RespondingUnit(name:"L-6"),
        RespondingUnit(name:"L-61"),
        RespondingUnit(name:"L-78"),
        RespondingUnit(name:"L-8"),
        RespondingUnit(name:"L-80"),
        RespondingUnit(name:"L-81"),
        RespondingUnit(name:"L-82"),
        RespondingUnit(name:"L-83"),
        RespondingUnit(name:"L-84"),
        RespondingUnit(name:"Marine 1"),
        RespondingUnit(name:"Marine 3"),
        RespondingUnit(name:"Marine 4"),
        RespondingUnit(name:"Marine 6"),
        RespondingUnit(name:"Marine 8"),
        RespondingUnit(name:"Marine 9"),
        RespondingUnit(name:"Marine Bn"),
        RespondingUnit(name:"Rescue 1"),
        RespondingUnit(name:"Rescue 2"),
        RespondingUnit(name:"Rescue 3"),
        RespondingUnit(name:"Rescue 4"),
        RespondingUnit(name:"Rescue 5"),
        RespondingUnit(name:"SQ-18"),
        RespondingUnit(name:"SQ-252"),
        RespondingUnit(name:"SQ-270"),
        RespondingUnit(name:"SQ-288"),
        RespondingUnit(name:"SQ-41"),
        RespondingUnit(name:"SQ-61"),
        RespondingUnit(name:"SQ-8"),
        RespondingUnit(name:"Squad 1"),
        RespondingUnit(name:"TL-1"),
        RespondingUnit(name:"TL-105"),
        RespondingUnit(name:"TL-107"),
        RespondingUnit(name:"TL-111"),
        RespondingUnit(name:"TL-114"),
        RespondingUnit(name:"TL-115"),
        RespondingUnit(name:"TL-117"),
        RespondingUnit(name:"TL-119"),
        RespondingUnit(name:"TL-12"),
        RespondingUnit(name:"TL-120"),
        RespondingUnit(name:"TL-121"),
        RespondingUnit(name:"TL-124"),
        RespondingUnit(name:"TL-127"),
        RespondingUnit(name:"TL-13"),
        RespondingUnit(name:"TL-131"),
        RespondingUnit(name:"TL-135"),
        RespondingUnit(name:"TL-138"),
        RespondingUnit(name:"TL-14"),
        RespondingUnit(name:"TL-142"),
        RespondingUnit(name:"TL-144"),
        RespondingUnit(name:"TL-146"),
        RespondingUnit(name:"TL-15"),
        RespondingUnit(name:"TL-152"),
        RespondingUnit(name:"TL-153"),
        RespondingUnit(name:"TL-155"),
        RespondingUnit(name:"TL-157"),
        RespondingUnit(name:"TL-158"),
        RespondingUnit(name:"TL-159"),
        RespondingUnit(name:"TL-160"),
        RespondingUnit(name:"TL-162"),
        RespondingUnit(name:"TL-163"),
        RespondingUnit(name:"TL-17"),
        RespondingUnit(name:"TL-170"),
        RespondingUnit(name:"TL-172"),
        RespondingUnit(name:"TL-18"),
        RespondingUnit(name:"TL-21"),
        RespondingUnit(name:"TL-22"),
        RespondingUnit(name:"TL-23"),
        RespondingUnit(name:"TL-31"),
        RespondingUnit(name:"TL-33"),
        RespondingUnit(name:"TL-35"),
        RespondingUnit(name:"TL-41"),
        RespondingUnit(name:"TL-44"),
        RespondingUnit(name:"TL-45"),
        RespondingUnit(name:"TL-46"),
        RespondingUnit(name:"TL-50"),
        RespondingUnit(name:"TL-51"),
        RespondingUnit(name:"TL-53"),
        RespondingUnit(name:"TL-54"),
        RespondingUnit(name:"TL-58"),
        RespondingUnit(name:"TL-7"),
        RespondingUnit(name:"TL-76"),
        RespondingUnit(name:"TL-77"),
        RespondingUnit(name:"TL-79"),
        RespondingUnit(name:"TL-85"),
        RespondingUnit(name:"TL-86"),
        RespondingUnit(name:"TL-87"),
        RespondingUnit(name:"TL-9")
    ]
}

class RespondingUnit: NSObject, UniqueProperty {
    let name: String
    
    init(name: String) {
        self.name = name
    }
    
    func uniquePropertyName() -> String {
        return "name"
    }
}


