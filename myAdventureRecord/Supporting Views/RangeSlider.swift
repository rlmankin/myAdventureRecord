import SwiftUI


public struct RangeSlider: View {
	/// ` Slider` Binding min & max values
	@Binding var boundLowerValue: Double
	@Binding var boundUpperValue: Double
	let range : ClosedRange<Double>
	@State private var lowerXValue : CGFloat
	@State private var upperXValue : CGFloat
	
	let label : String
	let sliderFrameWidth : Double
	
	init( 	boundLowerValue: Binding<Double>,
			boundUpperValue: Binding<Double>,
			range : ClosedRange<Double>,
			label : String,
			sliderFrameWidth : Double ) {
		self._boundLowerValue = boundLowerValue
		self._boundUpperValue = boundUpperValue
		self.range = range
		self.label = label
		self.sliderFrameWidth = sliderFrameWidth
		self.lowerXValue = 0
		self.upperXValue = sliderFrameWidth-15
	}
	
	

	public var body: some View {
		
		let rangeSpan = range.upperBound - range.lowerBound
		let thumbdiameter : CGFloat = 15
		let adjustedSliderWidth = sliderFrameWidth - thumbdiameter
		let sliderHeight : CGFloat = 3
		
		func lowerRangeOffset(xValue: CGFloat) -> CGFloat {
			let offset = xValue / adjustedSliderWidth * rangeSpan + range.lowerBound
			return offset
		}
		
		func upperRangeOffset(xValue: CGFloat) -> CGFloat {
			let offset = xValue / adjustedSliderWidth * rangeSpan
			return offset
		}
		
		return
			VStack {
				
				
					// ZStack for the actual range slider view
				ZStack (alignment: Alignment(horizontal: .leading, vertical: .center)) {
					Rectangle()								// Base slider line
						.frame(width: adjustedSliderWidth, height: sliderHeight)
						.offset(x:thumbdiameter/2)
						.foregroundColor(Color.green)
					// lower bound thumb and text
					VStack(alignment: .center) {
						Circle()							//the lower thumb
							.frame(width: thumbdiameter, height: thumbdiameter)
							.offset(x: lowerXValue-thumbdiameter/2, y: thumbdiameter/2)
						Text(String(format: "%5.0f", boundLowerValue))		// the lower thumb value
							.foregroundColor(Color.white)
							.font(.footnote)
							.border(Color.green)
					}
					.gesture(DragGesture().onChanged( { (value) in
						if value.location.x >= 0 &&
							value.location.x <= sliderFrameWidth &&
							value.location.x <= upperXValue{
							lowerXValue = value.location.x
							self.boundLowerValue = Double(lowerRangeOffset(xValue: value.location.x))
						}
					}))
					//	upper bound thumb and text
					VStack(alignment: .center) {
						Circle()							//the upper thumb
							.frame(width: thumbdiameter, height: thumbdiameter)
							.offset(x:upperXValue-thumbdiameter/2, y: thumbdiameter/2)
						Text(String(format: "%5.0f", boundUpperValue))		// the upper thumb value
							.foregroundColor(Color.white)
							.font(.footnote)
							.offset(x:adjustedSliderWidth - 1.5*thumbdiameter)
							.border(Color.green)
					}
					.gesture(DragGesture().onChanged( { (value) in
						if value.location.x >= 0 &&
							value.location.x <= adjustedSliderWidth &&
							value.location.x > lowerXValue {
							upperXValue = value.location.x
							self.boundUpperValue = Double(upperRangeOffset(xValue: value.location.x))
						}
					}))
					
					
				}//.frame(height: 50)
			}
	}
}

struct RangeSlider_Previews: PreviewProvider {
	static var previews: some View {
		let filtervar = FilterVars()
		
		let sliderWidth = 450.0
		RangeSlider(boundLowerValue: .constant(-100), boundUpperValue: .constant(100), range: -100...100, label: "test", sliderFrameWidth: 500)
		
	}
}
