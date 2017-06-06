#ifndef SHADERMODEL_H
#define SHADERMODEL_H

#include <QObject>
#include <QStandardItemModel>
#include "shaderparameterinfo.h"

class ShaderParameterInfo;

class ShaderModel : public QStandardItemModel
{
    Q_OBJECT
    Q_PROPERTY(QString vertexShader READ vertexShader WRITE setVertexShader NOTIFY vertexShaderChanged)
    Q_PROPERTY(QString geometryShader READ geometryShader WRITE setGeometryShader NOTIFY geometryShaderChanged)
    Q_PROPERTY(QString tesselationControlShader READ tesselationControlShader WRITE setTesselationControlShader NOTIFY tesselationControlShaderChanged)
    Q_PROPERTY(QString tesselationEvaluationShader READ tesselationEvaluationShader WRITE setTesselationEvaluationShader NOTIFY tesselationEvaluationShaderChanged)
    Q_PROPERTY(QString fragmentShader READ fragmentShader WRITE setFragmentShader NOTIFY fragmentShaderChanged)
    Q_PROPERTY(QString computeShader READ computeShader WRITE setComputeShader NOTIFY computeShaderChanged)
    Q_PROPERTY(QStringList blacklist READ blacklist WRITE setBlacklist NOTIFY blacklistChanged)
    Q_PROPERTY(bool isValid READ isValid NOTIFY isValidChanged)
public:
    enum ShaderParameterRoles {
        ParameterName = Qt::DisplayRole,
        ParameterType = Qt::ToolTipRole,
        ParameterDatatype = Qt::UserRole,
        ParameterValue = Qt::UserRole + 1,
        ParameterUniformLocation = Qt::UserRole + 2,
        ParameterIsSubroutine = Qt::UserRole + 3,
        ParameterSubroutineValues = Qt::UserRole + 4,
        ParameterData = Qt::UserRole + 5 // This is used for creation of ui elements
    };
    Q_ENUM(ShaderParameterRoles)

    ShaderModel();
    ShaderModel(const ShaderModel &other);
    Q_INVOKABLE void syncModel();
    QStringList blacklist() const;
    QString vertexShader() const;
    QString geometryShader() const;
    QString tesselationControlShader() const;
    QString tesselationEvaluationShader() const;
    QString fragmentShader() const;
    QString computeShader() const;
    bool isValid() const;

public Q_SLOTS:
    void setBlacklist(QStringList blacklist);
    QHash<int, QByteArray> roleNames() const;
    void setVertexShader(QString vertexShader);
    void setGeometryShader(QString geometryShader);
    void setTesselationControlShader(QString tesselationControlShader);
    void setTesselationEvaluationShader(QString tesselationEvaluationShader);
    void setFragmentShader(QString fragmentShader);
    void setComputeShader(QString computeShader);

Q_SIGNALS:
    void blacklistChanged(QStringList blacklist);
    void vertexShaderChanged(QString vertexShader);
    void geometryShaderChanged(QString geometryShader);
    void tesselationControlShaderChanged(QString tesselationControlShader);
    void tesselationEvaluationShaderChanged(QString tesselationEvaluationShader);
    void fragmentShaderChanged(QString fragmentShader);
    void computeShaderChanged(QString computeShader);
    void isValidChanged(bool isValid);

private:
    QHash<int, QByteArray> m_roleNameMapping;
    QStringList m_blacklist;
    QHash<QString, ShaderParameterInfo*> m_parameters;
    QString m_vertexShader;
    QString m_geometryShader;
    QString m_tesselationControlShader;
    QString m_tesselationEvaluationShader;
    QString m_fragmentShader;
    QString m_computeShader;
    bool m_isValid;
};

Q_DECLARE_METATYPE(ShaderModel)
Q_DECLARE_METATYPE(ShaderModel::ShaderParameterRoles)

#endif // SHADERMODEL_H
