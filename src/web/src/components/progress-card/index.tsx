import React from 'react';
import ProgressBar from '@ramonak/react-progress-bar';
import './style.scss';


interface ProgressCardProps {
    numerator: number
    denominator: number
    color?: string
}

const ProgressCard: React.FC<ProgressCardProps> = ({numerator, denominator, color}) => {
    
    const progressPercentage = denominator !== 0 ? Math.round(100 * (numerator / denominator)) : 0
    
    const getColor = () => {
        if (color === 'auto') {
            if (progressPercentage >= 66) return 'limegreen'
            else if (progressPercentage >= 33) return 'orange'
            return 'red'
        }
        if (color === 'auto-reverse') {
            if (progressPercentage >= 66) return 'red'
            else if (progressPercentage >= 33) return 'orange'
            return 'limegreen'
        }
        return color
    }

    return (
        <div className="profile-main-container">
            <ProgressBar bgColor={getColor()} className="progress--bar" completed={progressPercentage}/>
        </div>
    )
}

export default ProgressCard