import Vapor
import Foundation

class Utils: NSObject {
	static func haversineDistance(la1: Double, lo1: Double, la2: Double, lo2: Double, radius: Double = 6367444.7) -> Double {
		
		let haversin = { (angle: Double) -> Double in
			return (1 - cos(angle))/2
		}
		
		let ahaversin = { (angle: Double) -> Double in
			return 2*asin(sqrt(angle))
		}
		
		// Converts from degrees to radians
		let dToR = { (angle: Double) -> Double in
			return (angle / 360) * 2 * Double.pi
		}
		
		let lat1 = dToR(la1)
		let lon1 = dToR(lo1)
		let lat2 = dToR(la2)
		let lon2 = dToR(lo2)
		
		return radius * ahaversin(haversin(lat2 - lat1) + cos(lat1) * cos(lat2) * haversin(lon2 - lon1))
	}
}