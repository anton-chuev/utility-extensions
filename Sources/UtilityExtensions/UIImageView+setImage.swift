import UIKit

public extension UIImageView {
    
    private static var imageTaskIDKey = "imageTaskID"
    
    internal var imageTaskID: TimeInterval? {
        get { getAssociatedObject(key: &Self.imageTaskIDKey) }
        set { setAssociatedObject(key: &Self.imageTaskIDKey, value: newValue) }
    }
    
    convenience init(named: String) {
        self.init(frame: .zero)
        self.image = UIImage(named: named)
    }
    
    convenience init(system: String) {
        self.init(frame: .zero)
        self.image = UIImage(systemName: system)
    }
}

public extension UIImageView {
    @discardableResult
    func setImage(_ image: UIImage?) -> Self {
        let taskID = Date.now.timeIntervalSince1970
        imageTaskID = taskID
        DispatchQueue.global().async {
            let preparedImage = image?.preparingForDisplay()
            DispatchQueue.main.async {
                self.image = preparedImage ?? image
            }
        }
        return self
    }
    
    @discardableResult
    func setImage(data: Data?) -> Self {
        DispatchQueue.global().async {
            if let data, let image = UIImage(data: data) {
                self.setImage(image)
            }
        }
        return self
    }
    
    @discardableResult
    func setImageTask(placeholder: UIImage? = nil, task: (_ completeWithData: @escaping (Data?) -> Void) -> Void) -> Self {
        if let placeholder {
            image = placeholder
        }
        let taskID = Date.now.timeIntervalSince1970
        imageTaskID = taskID
        
        task { data in
            if self.imageTaskID == taskID {
                self.setImage(data: data)
            }
        }
        return self
    }
    
    @discardableResult
    func setImageTask(placeholder: UIImage? = nil, task: (_ completeWithImage: @escaping (UIImage?) -> Void) -> Void) -> Self {
        if let placeholder {
            image = placeholder
        }
        let taskID = Date.now.timeIntervalSince1970
        imageTaskID = taskID
        
        task { image in
            if self.imageTaskID == taskID {
                self.setImage(image)
            }
        }
        return self
    }
}


extension UIImageView {
    func setImage(PDFdata: Data?) {
        setImageTask { completeWithImage in
            let height = self.frame.height
            
            DispatchQueue.global(qos: .userInteractive).async {
                guard
                    let PDFdata,
                    let provider = CGDataProvider(data: PDFdata as CFData),
                    let pdfDoc   = CGPDFDocument(provider),
                    let pdfPage  = pdfDoc.page(at: 1)
                else { return completeWithImage(nil) }
                
                let pageRect = pdfPage.getBoxRect(.mediaBox)
                let aspectRatio = pageRect.width / pageRect.height
                let imageHeight = height
                let imageWidth = imageHeight * aspectRatio
                let scale = height / pageRect.height
                let imageRect = CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)
                
                let renderer = UIGraphicsImageRenderer(size: imageRect.size)
                let img = renderer.image { ctx in
                    UIColor.clear.set()
                    ctx.fill(imageRect)
                    
                    ctx.cgContext.translateBy(x: 0.0, y: imageRect.size.height)
                    ctx.cgContext.scaleBy(x: scale, y: -scale)
                    
                    ctx.cgContext.drawPDFPage(pdfPage)
                }
                completeWithImage(img)
            }
        }
    }
}

