import UIKit

/*@IBDesignable*/ class RatingControl: UIStackView {
    
    // MARK: Properties
    
    /*@IBInspectable*/ var starSize: CGSize = CGSize(width: 50.0, height: 50.0) {
        didSet {
            setupButtons()
        }
    }
    
    /*@IBInspectable*/ var starCount: Int = 5 {
        didSet {
            setupButtons()
        }
    }
    
    private var ratingButtons = [UIButton]()
    
    // property observer
    var rating = 0 {
        didSet {
            updateButtonSelectionState()
        }
    }
    
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    
    // MARK: Button Action
    
    @objc func ratingButtonTapped(button: UIButton) {
        
        guard let index = ratingButtons.firstIndex(of: button) else {
            fatalError("The button, \(button), is not in the ratingButtons array: \(ratingButtons)")
        }
        
        // calculate the rating of the selected button
        let selectedRating = index + 1
        if selectedRating == rating {
            // If the selected the star represents the current rating, reset the rating to the 0.
            rating = 0
        } else{
            // Otherwise set the rating to the selected star.
            rating = selectedRating
        }
    }

    
    // MARK: Private Methods
    
    private func setupButtons(){
        
        // (7) Load Button Images
        let bundle = Bundle(for: type(of: self))
        
        let emptyStar = UIImage(named: "emptyStar", in: bundle, compatibleWith: self.traitCollection)
        let filledStar = UIImage(named: "filledStar", in: bundle, compatibleWith: self.traitCollection)
        let highlightedStar = UIImage(named: "highlightesStar", in: bundle, compatibleWith: self.traitCollection)
        
        // (6) Clear any existing buttons
        for button in ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        ratingButtons.removeAll()
        
        for index in 0 ..< starCount {
            // (1) Create the button
            let button = UIButton()
            
            // (8) Set the button images
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            button.setImage(highlightedStar, for: .highlighted)
            button.setImage(highlightedStar, for: [.highlighted, .selected])
            
            // (2) Add constraints
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            
            // (9) Set the accessibility label
            button.accessibilityLabel = "Set \(index + 1) star rating"
            
            // (4) Setup the button action
            button.addTarget(self, action: #selector(RatingControl.ratingButtonTapped(button:)), for: .touchUpInside)
            
            // (3) Add the button to the stack
            addArrangedSubview(button)
            
            // (5) Add the new button to rating button array
            ratingButtons.append(button)
        }
        updateButtonSelectionState()
    }
    
    private func updateButtonSelectionState() {
        
        // enumerated 添字と要素が　タプルで取得出来る
        for (index, button) in ratingButtons.enumerated() {
            // If the index of a button is less than the rating, that button should be selected.
            button.isSelected = index < rating
            
            // set the hint string for the currently selected star
            let hintString: String?
            if rating == index + 1 {
                hintString = "Tap to reset the rating to zero."
            } else {
                hintString = nil
            }
            
            // Calculate the value string
            let valueString: String
            switch rating {
            case 0:
                valueString = "No rating set."
            case 1:
                valueString = "1 star set."
            default:
                valueString = "\(rating) star set."
            }
            
            // Assign the hint string and the value string
            button.accessibilityHint = hintString
            button.accessibilityValue = valueString
        }
    }
}
