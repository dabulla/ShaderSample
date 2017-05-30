#ifndef SHADERPARAMETERINFO_H
#define SHADERPARAMETERINFO_H

#include <QString>
#include "shadermodel.h"

class ShaderParameterInfo
{
public:
    QString m_name;
    ShaderModel::ShaderParameterType m_type;
    ShaderModel::ShaderParameterDatatype m_datatype;
    QVariant    m_value;
    int         m_uniformLocation;
    bool        m_isSubroutine;
    QStringList m_subroutineValues;
    ShaderParameterInfo();
};

#endif // SHADERPARAMETERINFO_H
