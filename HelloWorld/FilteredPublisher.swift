
import Foundation
import OpenTok
import GPUImage

class FilteredPublisher:  OTPublisherKit, OTVideoCapture, GPUImageVideoCameraDelegate {
    
    let imageHeight = 240
    let imageWidth = 320
    
    weak var videoCaptureConsumer: OTVideoCaptureConsumer!
    var videoCamera: GPUImageVideoCamera?
    let sepiaImageFilter = GPUImageSepiaFilter()
    var videoFrame = OTVideoFrame()
    var view = GPUImageView()
    
    override init() {
        super.init()
    }
    
    override init!(delegate: OTPublisherKitDelegate!) {
        super.init(delegate: delegate)
    }
    
    override init!(delegate: OTPublisherKitDelegate!, name: String!, audioTrack: Bool, videoTrack: Bool) {
        super.init(delegate: delegate, name: name, audioTrack: audioTrack, videoTrack: videoTrack)
    }
    
    
    override init!(delegate: OTPublisherKitDelegate!, name: String!){
        super.init(delegate: delegate, name: name)
        
        self.view = GPUImageView(frame: CGRectMake(0,0,1,1))
        self.videoCapture = self
        
        let format = OTVideoFormat()
        format.pixelFormat = OTPixelFormat.NV12
        format.imageWidth = UInt32(imageWidth)
        format.imageHeight = UInt32(imageHeight)
        self.videoFrame = OTVideoFrame(format: format)
    }
    
    
    func willOutputSampleBuffer(sampleBuffer: CMSampleBuffer!) {
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        CVPixelBufferLockBaseAddress(imageBuffer!, 0)
        videoFrame?.clearPlanes()
        for var i = 0 ; i < CVPixelBufferGetPlaneCount(imageBuffer!); i++ {
            print(i)
            videoFrame?.planes.addPointer(CVPixelBufferGetBaseAddressOfPlane(imageBuffer!, i))
        }
        videoFrame?.orientation = OTVideoOrientation.Left
        videoCaptureConsumer.consumeFrame(videoFrame) //comment this out to stop app from crashing
        CVPixelBufferUnlockBaseAddress(imageBuffer!, 0)
    }
    
    
    
    func initCapture(){
        videoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSessionPreset640x480, cameraPosition: AVCaptureDevicePosition.Front)
        videoCamera?.outputImageOrientation = UIInterfaceOrientation.Portrait
        videoCamera?.delegate = self
        
        let sepia = GPUImageSepiaFilter()
        videoCamera?.addTarget(sepia)
        sepia.addTarget(self.view)
        
        videoCamera?.addTarget(self.view)
        videoCamera?.startCameraCapture()
    }
    
    
    func releaseCapture(){
        videoCamera?.delegate = nil
        videoCamera = nil
    }
    
    
    func startCapture() -> Int32{
        return 0
    }
    
    
    func stopCapture() -> Int32{
        return 0
    }
    
    
    func isCaptureStarted() -> Bool{
        return true
    }
    
    
    func captureSettings(videoFormat: OTVideoFormat!) -> Int32{
        videoFormat.pixelFormat = OTPixelFormat.NV12
        videoFormat.imageWidth = UInt32(imageWidth)
        videoFormat.imageHeight = UInt32(imageHeight)
        return 0;
    }
}